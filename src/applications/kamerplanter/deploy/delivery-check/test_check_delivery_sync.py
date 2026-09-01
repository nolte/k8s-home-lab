#!/usr/bin/env python3
"""Self-test for :mod:`check_delivery_sync`.

Runs on the standard library alone (``unittest``), because this repository has
no Python test lane and adding one would be inventing a convention rather than
following one. It is wired into the repository's existing gate as a local
pre-commit hook, so it runs where every other check here runs.

Two things this file deliberately does that a coverage-shaped test suite would
not:

* **It induces ``drift``.** That verdict is the whole point of the check and is
  the one class that cannot be induced against the live cluster without breaking
  the live cluster, so it is induced here instead — once per route into it.
* **It falsifies its own guards.** For every rule that says "this is NOT
  softened", there is a paired case that *is* softened under the identical
  expression, so a green result proves the rule discriminates rather than that
  the branch was merely executed.
"""

from __future__ import annotations

import io
import json
import os
import sys
import tempfile
import unittest
from contextlib import redirect_stdout
from datetime import UTC, datetime, timedelta

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import check_delivery_sync as check  # noqa: E402

NOW = datetime(2026, 9, 1, 12, 0, 0, tzinfo=UTC)
LONG_AGO = (NOW - timedelta(days=3)).isoformat().replace("+00:00", "Z")
JUST_NOW = (NOW - timedelta(minutes=5)).isoformat().replace("+00:00", "Z")

DIGEST_A = "sha256:" + "a" * 64
DIGEST_B = "sha256:" + "b" * 64


def declared(version: str = "0.2.1", name: str = "kamerplanter") -> check.Declared:
    """Build a declared operand.

    Args:
        version: The declared chart version.
        name: The declared chart name.

    Returns:
        The declared operand.
    """
    return check.Declared(
        chart_name=name,
        version=version,
        repo_url=f"oci://ghcr.io/nolte/charts/{name}",
        source_index=1,
        prerelease="-" in version,
    )


def settled(finished_at: str = LONG_AGO) -> check.ArgoState:
    """Build an ArgoCD self-report of a long-settled, green Application.

    Args:
        finished_at: When the last sync operation completed.

    Returns:
        The self-report.
    """
    return check.ArgoState(
        sync_status="Synced",
        health_status="Healthy",
        operation_phase="Succeeded",
        operation_finished_at=finished_at,
        reconciled_at=finished_at,
    )


def controller(
    kind: str = "Deployment",
    name: str = "kamerplanter-backend",
    *,
    chart_label: str | None = "kamerplanter-0.2.1",
    generation: int = 4,
    observed: int | None = 4,
    replicas: int = 1,
    updated: int | None = None,
    ready: int | None = None,
    available: int | None = None,
    conditions: list[dict] | None = None,
    status_extra: dict | None = None,
    selector: dict[str, str] | None = None,
) -> check.Controller:
    """Build a controller in a fully-rolled-out state unless told otherwise.

    Args:
        kind: Controller kind.
        name: Controller name.
        chart_label: Value of the chart label, or None for no label.
        generation: ``metadata.generation``.
        observed: ``status.observedGeneration``.
        replicas: ``status.replicas``.
        updated: ``status.updatedReplicas``, defaulting to *replicas*.
        ready: ``status.readyReplicas``, defaulting to *replicas*.
        available: ``status.availableReplicas``, defaulting to *replicas*.
        conditions: ``status.conditions``.
        status_extra: Extra ``status`` fields.
        selector: ``spec.selector.matchLabels``.

    Returns:
        The controller.
    """
    status = {
        "replicas": replicas,
        "updatedReplicas": replicas if updated is None else updated,
        "readyReplicas": replicas if ready is None else ready,
        "availableReplicas": replicas if available is None else available,
    }
    status.update(status_extra or {})
    resolved_selector = selector if selector is not None else {"app": name}
    return check.Controller(
        kind=kind,
        name=name,
        chart_label=chart_label,
        chart_version=None,
        generation=generation,
        observed_generation=observed,
        selector=resolved_selector,
        selector_readable=bool(resolved_selector),
        status=status,
        conditions=conditions or [],
    )


class DeclaredSideTest(unittest.TestCase):
    """The declared operand, resolved before anything else is read."""

    def test_oci_source_yields_chart_name_and_version(self) -> None:
        """An `oci://` source names its chart in the last repoURL segment."""
        application = {
            "spec": {
                "sources": [
                    {"repoURL": "https://github.com/x/y.git", "path": "charts/mixin", "targetRevision": "main"},
                    {"repoURL": "oci://ghcr.io/nolte/charts/kamerplanter", "path": ".", "targetRevision": "0.2.1"},
                ]
            }
        }
        resolved = check.resolve_declared(application, source_index=None, chart_name=None)
        self.assertEqual(resolved.chart_name, "kamerplanter")
        self.assertEqual(resolved.version, "0.2.1")
        self.assertEqual(resolved.source_index, 1)

    def test_classic_chart_source_is_recognised(self) -> None:
        """A repository source with `chart:` is a candidate too."""
        application = {"spec": {"source": {"repoURL": "https://charts.example", "chart": "pihole", "targetRevision": "2.38.0"}}}
        resolved = check.resolve_declared(application, source_index=None, chart_name=None)
        self.assertEqual((resolved.chart_name, resolved.version), ("pihole", "2.38.0"))

    def test_floating_target_revision_is_undetermined_not_drift(self) -> None:
        """A branch names no chart version, so the comparison cannot run."""
        application = {"spec": {"sources": [{"repoURL": "oci://ghcr.io/x/y", "targetRevision": "main"}]}}
        with self.assertRaises(check.DeliverySyncError) as caught:
            check.resolve_declared(application, source_index=None, chart_name=None)
        self.assertIn("not a fixed chart version", str(caught.exception))
        self.assertIn("NOT drift", str(caught.exception))

    def test_every_floating_spelling_is_rejected(self) -> None:
        """Ranges, wildcards, HEAD and bare commits are all uncomparable."""
        for revision in ("*", "1.2.x", ">=1.2.0", "~1.2", "HEAD", "master", "a" * 40, ""):
            application = {"spec": {"sources": [{"repoURL": "oci://ghcr.io/x/y", "targetRevision": revision}]}}
            with self.assertRaises(check.DeliverySyncError, msg=revision):
                check.resolve_declared(application, source_index=None, chart_name=None)

    def test_prerelease_version_is_accepted_and_flagged(self) -> None:
        """A pre-release is comparable, but its immutability is weaker."""
        application = {"spec": {"sources": [{"repoURL": "oci://ghcr.io/x/y", "targetRevision": "0.2.2-dev.4"}]}}
        resolved = check.resolve_declared(application, source_index=None, chart_name=None)
        self.assertTrue(resolved.prerelease)

    def test_several_chart_sources_refuse_to_guess(self) -> None:
        """Ambiguity is named, never resolved by picking the first."""
        application = {
            "spec": {
                "sources": [
                    {"repoURL": "https://charts.example", "chart": "argo-cd", "targetRevision": "10.4.0"},
                    {"repoURL": "https://charts.example", "chart": "argocd-apps", "targetRevision": "2.0.5"},
                ]
            }
        }
        with self.assertRaises(check.DeliverySyncError) as caught:
            check.resolve_declared(application, source_index=None, chart_name=None)
        self.assertIn("--source-index", str(caught.exception))

    def test_no_chart_source_is_undetermined(self) -> None:
        """A pure kustomize Application declares no chart version at all."""
        application = {"spec": {"source": {"repoURL": "https://github.com/x/y.git", "path": "p", "targetRevision": "master"}}}
        with self.assertRaises(check.DeliverySyncError) as caught:
            check.resolve_declared(application, source_index=None, chart_name=None)
        self.assertIn("names a Helm chart", str(caught.exception))

    def test_source_index_out_of_range_is_named(self) -> None:
        """A bad --source-index is reported as itself."""
        application = {"spec": {"sources": [{"repoURL": "oci://ghcr.io/x/y", "targetRevision": "1.0.0"}]}}
        with self.assertRaises(check.DeliverySyncError) as caught:
            check.resolve_declared(application, source_index=7, chart_name=None)
        self.assertIn("out of range", str(caught.exception))


class AppliedSideThreeAnswersTest(unittest.TestCase):
    """The three answers on the applied side, kept distinct."""

    def test_third_answer_a_real_version_reaches_the_comparison(self) -> None:
        """A parsable label naming the declared chart is the only real answer."""
        versions = check.applied_versions([controller()], declared(), check.DEFAULT_CHART_LABEL)
        self.assertEqual(versions, {"0.2.1": ["Deployment/kamerplanter-backend"]})

    def test_first_answer_no_label_is_not_disclosed_and_not_drift(self) -> None:
        """No chart label anywhere: the check cannot run, and says so."""
        with self.assertRaises(check.ChartVersionNotDisclosedError) as caught:
            check.applied_versions([controller(chart_label=None)], declared(), check.DEFAULT_CHART_LABEL)
        message = str(caught.exception)
        self.assertIn("helm.sh/chart", message)
        self.assertIn("may be perfectly current", message)
        self.assertIn("--chart-label chart", message)
        self.assertNotIn("drift", message.lower().replace("not drift", ""))

    def test_first_answer_covers_subchart_only_namespaces(self) -> None:
        """Labels that name other charts are not an answer about this one."""
        with self.assertRaises(check.ChartVersionNotDisclosedError) as caught:
            check.applied_versions(
                [controller(name="kamerplanter-valkey", chart_label="valkey-0.10.0")],
                declared(),
                check.DEFAULT_CHART_LABEL,
            )
        self.assertIn("valkey-0.10.0", str(caught.exception))

    def test_second_answer_unparsable_version_is_undetermined(self) -> None:
        """The label names the chart but says nothing comparable."""
        with self.assertRaises(check.ChartVersionUnknownError) as caught:
            check.applied_versions(
                [controller(chart_label="kamerplanter-")], declared(), check.DEFAULT_CHART_LABEL
            )
        self.assertIn("not a version", str(caught.exception))

    def test_the_three_answers_have_three_distinct_types(self) -> None:
        """Collapsing any two of them would defeat the contract."""
        self.assertTrue(issubclass(check.ChartVersionNotDisclosedError, check.DeliverySyncError))
        self.assertTrue(issubclass(check.ChartVersionUnknownError, check.DeliverySyncError))
        self.assertIsNot(check.ChartVersionNotDisclosedError, check.ChartVersionUnknownError)

    def test_subchart_beside_parent_chart_does_not_pollute_the_set(self) -> None:
        """A subchart's own version must not look like a split apply."""
        versions = check.applied_versions(
            [controller(), controller(name="kamerplanter-valkey", chart_label="valkey-0.10.0")],
            declared(),
            check.DEFAULT_CHART_LABEL,
        )
        self.assertEqual(sorted(versions), ["0.2.1"])

    def test_prerelease_version_in_the_label_is_parsed_whole(self) -> None:
        """`kamerplanter-0.2.2-rc.1` is version `0.2.2-rc.1`, not `rc.1`.

        A naive rsplit on '-' would produce the wrong answer here, silently.
        """
        versions = check.applied_versions(
            [controller(chart_label="kamerplanter-0.2.2-rc.1")], declared("0.2.2-rc.1"), check.DEFAULT_CHART_LABEL
        )
        self.assertEqual(sorted(versions), ["0.2.2-rc.1"])

    def test_a_subchart_whose_name_extends_the_parent_is_not_the_parent(self) -> None:
        """`kamerplanter-exporter-1.0.0` starts with the prefix but is not it.

        The remainder carries a version of its own, so the label names a
        different chart rather than this one with a broken version.
        """
        with self.assertRaises(check.ChartVersionNotDisclosedError):
            check.applied_versions(
                [controller(chart_label="kamerplanter-exporter-1.0.0")], declared(), check.DEFAULT_CHART_LABEL
            )

    def test_this_chart_with_a_non_semver_version_is_the_unknown_class(self) -> None:
        """Paired with the case above: no version anywhere in the remainder.

        `kamerplanter-latest` is this chart carrying a version that cannot be
        compared, which is the second answer rather than the first. Both stay
        RED with no drift alert; only the sentence the operator reads differs.
        """
        with self.assertRaises(check.ChartVersionUnknownError):
            check.applied_versions(
                [controller(chart_label="kamerplanter-latest")], declared(), check.DEFAULT_CHART_LABEL
            )


class RolloutFindingsTest(unittest.TestCase):
    """The operand `status.sync.status == "Synced"` cannot supply."""

    def test_a_settled_controller_produces_no_finding(self) -> None:
        """The negative control for every case below."""
        self.assertEqual(check.rollout_findings([controller()]), [])

    def test_unobserved_generation_is_a_finding(self) -> None:
        """The applied spec has not been acted on yet."""
        kinds = [f.kind for f in check.rollout_findings([controller(generation=5, observed=4)])]
        self.assertIn("generation_not_observed", kinds)

    def test_progress_deadline_exceeded_is_conclusive(self) -> None:
        """Kubernetes has already declared the rollout stuck."""
        findings = check.rollout_findings(
            [
                controller(
                    ready=0,
                    available=0,
                    conditions=[{"type": "Progressing", "status": "False", "reason": "ProgressDeadlineExceeded"}],
                )
            ]
        )
        stuck = [f for f in findings if f.kind == "progress_deadline_exceeded"]
        self.assertEqual(len(stuck), 1)
        self.assertTrue(stuck[0].conclusive)

    def test_a_healthy_progressing_condition_is_not_a_finding(self) -> None:
        """Falsification: `Progressing=True/NewReplicaSetAvailable` is the settled state.

        This is what the live reference deployment reports, so a rule that
        merely looked at the `Progressing` type would be permanently red.
        """
        findings = check.rollout_findings(
            [controller(conditions=[{"type": "Progressing", "status": "True", "reason": "NewReplicaSetAvailable"}])]
        )
        self.assertEqual(findings, [])

    def test_statefulset_revision_split_is_never_softened(self) -> None:
        """A StatefulSet half-recreated is a split, not progress."""
        findings = check.rollout_findings(
            [
                controller(
                    kind="StatefulSet",
                    status_extra={"currentRevision": "sts-aaa", "updateRevision": "sts-bbb"},
                )
            ]
        )
        split = [f for f in findings if f.kind == "statefulset_revision_split"]
        self.assertEqual(len(split), 1)
        self.assertTrue(split[0].never_softened)

    def test_daemonset_uses_its_own_counters(self) -> None:
        """A DaemonSet has node counts, not replica counts."""
        findings = check.rollout_findings(
            [
                controller(
                    kind="DaemonSet",
                    status_extra={
                        "desiredNumberScheduled": 3,
                        "updatedNumberScheduled": 2,
                        "numberReady": 2,
                        "numberAvailable": 2,
                    },
                )
            ]
        )
        self.assertIn("rollout_incomplete", [f.kind for f in findings])

    def test_a_complete_daemonset_produces_no_finding(self) -> None:
        """Falsification for the DaemonSet branch."""
        findings = check.rollout_findings(
            [
                controller(
                    kind="DaemonSet",
                    status_extra={
                        "desiredNumberScheduled": 3,
                        "updatedNumberScheduled": 3,
                        "numberReady": 3,
                        "numberAvailable": 3,
                    },
                )
            ]
        )
        self.assertEqual(findings, [])


class ImageFidelityTest(unittest.TestCase):
    """The #1024 failure: a node serving other bytes than the chart pinned."""

    @staticmethod
    def _pod(image: str, image_id: str, name: str = "p-1") -> dict:
        return {
            "metadata": {"name": name, "labels": {"app": "kamerplanter-backend"}},
            "spec": {"containers": [{"name": "main", "image": image}]},
            "status": {"containerStatuses": [{"name": "main", "imageID": image_id}]},
        }

    def test_matching_digests_produce_no_finding(self) -> None:
        """The negative control."""
        pods = [self._pod(f"ghcr.io/x/y:0.2.1@{DIGEST_A}", f"ghcr.io/x/y@{DIGEST_A}")]
        findings, skipped = check.image_findings([controller()], pods)
        self.assertEqual(findings, [])
        self.assertEqual(skipped, [])

    def test_divergent_digest_is_a_conclusive_finding(self) -> None:
        """Different digests are different bytes; there is nothing to wait for."""
        pods = [self._pod(f"ghcr.io/x/y:0.2.1@{DIGEST_A}", f"ghcr.io/x/y@{DIGEST_B}")]
        findings, _ = check.image_findings([controller()], pods)
        self.assertEqual([f.kind for f in findings], ["image_digest_mismatch"])
        self.assertTrue(findings[0].conclusive)

    def test_an_unpinned_image_is_skipped_not_counted_clean(self) -> None:
        """A tag-only reference has nothing to compare; it must be visible."""
        pods = [self._pod("docker.io/valkey/valkey:9.1.0", f"docker.io/valkey/valkey@{DIGEST_A}")]
        findings, skipped = check.image_findings([controller()], pods)
        self.assertEqual(findings, [])
        self.assertEqual(len(skipped), 1)
        self.assertIn("not digest-pinned", skipped[0])

    def test_a_controller_without_matchlabels_is_skipped_visibly(self) -> None:
        """An unmatchable selector must not silently look like a clean pass."""
        findings, skipped = check.image_findings([controller(selector={})], [])
        self.assertEqual(findings, [])
        self.assertIn("no matchLabels selector", skipped[0])


class DecideTest(unittest.TestCase):
    """The verdict, including every route into `drift`."""

    def _decide(self, by_version, findings, argo=None, grace=60.0, dec=None):
        return check.decide(
            dec or declared(),
            by_version,
            findings,
            argo or settled(),
            now=NOW,
            grace_minutes=grace,
        )

    def test_match(self) -> None:
        """Declared equals applied and everything rolled out."""
        verdict, findings = self._decide({"0.2.1": ["Deployment/a"]}, [])
        self.assertEqual(verdict.name, check.VERDICT_MATCH)
        self.assertEqual(findings, [])
        self.assertFalse(verdict.is_alert)

    def test_drift_declared_version_never_applied(self) -> None:
        """The 2026-08-17 shape: ArgoCD says Synced, the workloads are old."""
        verdict, findings = self._decide({"0.2.0": ["Deployment/a"]}, [])
        self.assertEqual(verdict.name, check.VERDICT_DRIFT)
        self.assertTrue(verdict.is_alert)
        self.assertEqual([f.kind for f in findings], ["declared_version_not_applied"])
        self.assertIn("0.2.0", verdict.detail)

    def test_drift_is_reported_despite_a_green_argocd_self_report(self) -> None:
        """Falsification: the self-report must not be able to veto the verdict."""
        green = check.ArgoState(
            sync_status="Synced",
            health_status="Healthy",
            operation_phase="Succeeded",
            operation_finished_at=LONG_AGO,
        )
        verdict, _ = self._decide({"0.2.0": ["Deployment/a"]}, [], argo=green)
        self.assertEqual(verdict.name, check.VERDICT_DRIFT)

    def test_within_grace_when_the_sync_is_fresh(self) -> None:
        """The same mismatch minutes after an apply is not yet alertable."""
        verdict, _ = self._decide({"0.2.0": ["Deployment/a"]}, [], argo=settled(JUST_NOW))
        self.assertEqual(verdict.name, check.VERDICT_WITHIN_GRACE)
        self.assertFalse(verdict.is_alert)

    def test_split_apply_is_drift_even_inside_the_grace_window(self) -> None:
        """The property #1318's sampling exists to protect, kept explicitly.

        The paired case below shows the softening path is real, so this is not
        green merely because nothing is ever softened.
        """
        verdict, findings = self._decide(
            {"0.2.1": ["Deployment/a"], "0.2.0": ["Deployment/b"]}, [], argo=settled(JUST_NOW)
        )
        self.assertEqual(verdict.name, check.VERDICT_DRIFT)
        self.assertEqual(findings[0].kind, "applied_version_split")

    def test_paired_falsification_a_rollout_finding_IS_softened_in_the_same_window(self) -> None:
        """Same grace window, same anchor, softenable finding -> `rolling`."""
        verdict, _ = self._decide(
            {"0.2.1": ["Deployment/a"]},
            [check.Finding("rollout_incomplete", "still rolling")],
            argo=settled(JUST_NOW),
        )
        self.assertEqual(verdict.name, check.VERDICT_ROLLING)
        self.assertFalse(verdict.is_alert)

    def test_the_same_rollout_finding_becomes_drift_past_the_window(self) -> None:
        """A rollout does not take three days."""
        verdict, _ = self._decide(
            {"0.2.1": ["Deployment/a"]}, [check.Finding("rollout_incomplete", "still rolling")]
        )
        self.assertEqual(verdict.name, check.VERDICT_DRIFT)

    def test_conclusive_findings_bypass_the_grace_window(self) -> None:
        """Kubernetes already concluded; waiting adds nothing."""
        verdict, _ = self._decide(
            {"0.2.1": ["Deployment/a"]},
            [check.Finding("progress_deadline_exceeded", "stuck", conclusive=True)],
            argo=settled(JUST_NOW),
        )
        self.assertEqual(verdict.name, check.VERDICT_DRIFT)

    def test_a_failed_sync_operation_is_drift(self) -> None:
        """ArgoCD itself says it did not apply the declared state."""
        failed = check.ArgoState(
            sync_status="OutOfSync",
            health_status="Healthy",
            operation_phase="Failed",
            operation_finished_at=JUST_NOW,
            operation_message="one or more objects failed to apply",
        )
        verdict, findings = self._decide({"0.2.1": ["Deployment/a"]}, [], argo=failed)
        self.assertEqual(verdict.name, check.VERDICT_DRIFT)
        self.assertIn("sync_operation_failed", [f.kind for f in findings])

    def test_a_running_sync_is_rolling(self) -> None:
        """A sync in flight explains the findings without alerting."""
        running = check.ArgoState(operation_phase="Running", operation_finished_at=None, reconciled_at=JUST_NOW)
        verdict, _ = self._decide({"0.2.0": ["Deployment/a"]}, [], argo=running)
        self.assertEqual(verdict.name, check.VERDICT_ROLLING)

    def test_versions_are_compared_exactly_with_no_v_normalisation(self) -> None:
        """`v0.2.1` and `0.2.1` are different strings, and stay different."""
        verdict, findings = self._decide({"v0.2.1": ["Deployment/a"]}, [])
        self.assertEqual(verdict.name, check.VERDICT_DRIFT)
        self.assertIn("leading 'v'", findings[0].message)

    def test_a_missing_anchor_is_undetermined_not_assumed(self) -> None:
        """No finishedAt and no reconciledAt: refuse to date the mismatch."""
        anchorless = check.ArgoState(sync_status="Synced", operation_phase="Succeeded")
        with self.assertRaises(check.DeliverySyncError) as caught:
            self._decide({"0.2.0": ["Deployment/a"]}, [], argo=anchorless)
        self.assertIn("no anchor", str(caught.exception))

    def test_reconciled_at_is_accepted_as_a_weaker_anchor(self) -> None:
        """A never-synced Application still has a datable moment."""
        weak = check.ArgoState(sync_status="Synced", operation_phase=None, reconciled_at=JUST_NOW)
        verdict, _ = self._decide({"0.2.0": ["Deployment/a"]}, [], argo=weak)
        self.assertEqual(verdict.name, check.VERDICT_WITHIN_GRACE)
        self.assertIn("weaker anchor", verdict.headline)

    def test_deciding_on_nothing_is_refused(self) -> None:
        """An empty applied set would otherwise read as a clean result."""
        with self.assertRaises(check.DeliverySyncError):
            self._decide({}, [])


class FakeApi:
    """A KubeApi-shaped double returning canned objects.

    Deliberately returns whole API-shaped documents rather than the parsed
    structures the check builds: a double that speaks the check's internal
    vocabulary would accept inputs the real API server can never produce.
    """

    def __init__(self, application: dict, controllers: dict[str, list[dict]], pods: list[dict]) -> None:
        self._application = application
        self._controllers = controllers
        self._pods = pods

    def application(self, namespace: str, name: str) -> dict:  # noqa: D102 - mirrors KubeApi
        return self._application

    def list_items(self, path: str) -> list[dict]:  # noqa: D102 - mirrors KubeApi
        if path.endswith("/pods"):
            return self._pods
        return self._controllers.get(path.rsplit("/", 1)[-1], [])


def api_deployment(name: str, chart: str, image: str) -> dict:
    """Build an API-shaped Deployment owned by the `kamerplanter` Application.

    Args:
        name: Deployment name.
        chart: Value of the `helm.sh/chart` label.
        image: Container image reference.

    Returns:
        The Deployment document.
    """
    return {
        "metadata": {
            "name": name,
            "generation": 3,
            "labels": {"helm.sh/chart": chart},
            "annotations": {check.TRACKING_ANNOTATION: f"kamerplanter:apps/Deployment:kamerplanter/{name}"},
        },
        "spec": {"selector": {"matchLabels": {"app": name}}, "template": {"spec": {"containers": [{"name": "main", "image": image}]}}},
        "status": {
            "observedGeneration": 3,
            "replicas": 1,
            "updatedReplicas": 1,
            "readyReplicas": 1,
            "availableReplicas": 1,
            "conditions": [{"type": "Progressing", "status": "True", "reason": "NewReplicaSetAvailable"}],
        },
    }


def api_pod(name: str, owner: str, image: str, image_id: str) -> dict:
    """Build an API-shaped pod selected by *owner*.

    Args:
        name: Pod name.
        owner: The Deployment whose selector it matches.
        image: `spec` image reference.
        image_id: `status` imageID.

    Returns:
        The pod document.
    """
    return {
        "metadata": {"name": name, "labels": {"app": owner}},
        "spec": {"containers": [{"name": "main", "image": image}]},
        "status": {"containerStatuses": [{"name": "main", "imageID": image_id}]},
    }


APPLICATION = {
    "spec": {
        "destination": {"namespace": "kamerplanter"},
        "sources": [
            {"repoURL": "https://github.com/x/y.git", "path": "charts/mixin", "targetRevision": "main"},
            {"repoURL": "oci://ghcr.io/nolte/charts/kamerplanter", "path": ".", "targetRevision": "0.2.1"},
        ],
    },
    "status": {
        "sync": {"status": "Synced"},
        "health": {"status": "Healthy"},
        "operationState": {"phase": "Succeeded", "finishedAt": LONG_AGO},
        "reconciledAt": LONG_AGO,
    },
}


class EndToEndTest(unittest.TestCase):
    """`main` end to end, over an API-shaped double."""

    def _run(self, chart: str, *, image_id: str | None = None, argv: list[str] | None = None):
        image = f"ghcr.io/nolte/kamerplanter-backend:0.2.1@{DIGEST_A}"
        api = FakeApi(
            APPLICATION,
            {"deployments": [api_deployment("kamerplanter-backend", chart, image)], "statefulsets": [], "daemonsets": []},
            [api_pod("kamerplanter-backend-1", "kamerplanter-backend", image, image_id or f"ghcr.io/x@{DIGEST_A}")],
        )
        with tempfile.TemporaryDirectory() as directory:
            report_path = os.path.join(directory, "report.json")
            buffer = io.StringIO()
            with redirect_stdout(buffer):
                code = check.run(
                    (argv or ["--application", "kamerplanter"]) + ["--json", report_path],
                    api=api,
                    now=NOW,
                )
            report = json.load(open(report_path, encoding="utf-8")) if os.path.exists(report_path) else None
        return code, buffer.getvalue(), report

    def test_match_exits_zero_and_writes_a_report(self) -> None:
        """The green path, end to end."""
        code, output, report = self._run("kamerplanter-0.2.1")
        self.assertEqual(code, check.EXIT_OK)
        self.assertEqual(report["verdict"], check.VERDICT_MATCH)
        self.assertEqual(report["findings"], [])
        self.assertIn("match", output)

    def test_drift_exits_three_and_the_report_says_why(self) -> None:
        """The incident. The report must never be a verdict without a reason."""
        code, _, report = self._run("kamerplanter-0.2.0")
        self.assertEqual(code, check.EXIT_DRIFT)
        self.assertEqual(report["verdict"], check.VERDICT_DRIFT)
        self.assertEqual([f["kind"] for f in report["findings"]], ["declared_version_not_applied"])
        self.assertEqual(report["argocd_self_report"]["sync_status"], "Synced")

    def test_image_drift_exits_three(self) -> None:
        """A node serving other bytes than the chart pinned."""
        code, _, report = self._run("kamerplanter-0.2.1", image_id=f"ghcr.io/x@{DIGEST_B}")
        self.assertEqual(code, check.EXIT_DRIFT)
        self.assertIn("image_digest_mismatch", [f["kind"] for f in report["findings"]])

    def test_not_disclosed_exits_one_and_writes_no_report(self) -> None:
        """An undetermined check must not leave a report a consumer can read."""
        api = FakeApi(
            APPLICATION,
            {
                "deployments": [
                    {
                        "metadata": {
                            "name": "kamerplanter-backend",
                            "generation": 1,
                            "annotations": {
                                check.TRACKING_ANNOTATION: "kamerplanter:apps/Deployment:kamerplanter/kamerplanter-backend"
                            },
                        },
                        "spec": {"selector": {"matchLabels": {"app": "kamerplanter-backend"}}},
                        "status": {"observedGeneration": 1},
                    }
                ],
                "statefulsets": [],
                "daemonsets": [],
            },
            [],
        )
        with tempfile.TemporaryDirectory() as directory:
            report_path = os.path.join(directory, "report.json")
            buffer = io.StringIO()
            with redirect_stdout(buffer):
                code = check.run(
                    ["--application", "kamerplanter", "--json", report_path], api=api, now=NOW
                )
            self.assertEqual(code, check.EXIT_UNDETERMINED)
            self.assertFalse(os.path.exists(report_path))

    def test_undetermined_declared_side_exits_one(self) -> None:
        """Forcing the floating source reproduces the live induction."""
        code, _, report = self._run(
            "kamerplanter-0.2.1", argv=["--application", "kamerplanter", "--source-index", "0"]
        )
        self.assertEqual(code, check.EXIT_UNDETERMINED)
        self.assertIsNone(report)

    def test_an_application_owning_nothing_is_undetermined(self) -> None:
        """No workload means no measurement, not a clean one."""
        api = FakeApi(APPLICATION, {"deployments": [], "statefulsets": [], "daemonsets": []}, [])
        with redirect_stdout(io.StringIO()):
            code = check.run(["--application", "kamerplanter"], api=api, now=NOW)
        self.assertEqual(code, check.EXIT_UNDETERMINED)

    def test_untracked_workloads_are_not_measured(self) -> None:
        """Ownership is the tracking annotation, never a coincidental label."""
        image = f"ghcr.io/nolte/kamerplanter-backend:0.2.1@{DIGEST_A}"
        stranger = api_deployment("kamerplanter-backend", "kamerplanter-0.2.1", image)
        stranger["metadata"]["annotations"] = {check.TRACKING_ANNOTATION: "somebody-else:apps/Deployment:x/y"}
        api = FakeApi(APPLICATION, {"deployments": [stranger], "statefulsets": [], "daemonsets": []}, [])
        with redirect_stdout(io.StringIO()):
            code = check.run(["--application", "kamerplanter"], api=api, now=NOW)
        self.assertEqual(code, check.EXIT_UNDETERMINED)

    def test_a_bad_invocation_exits_two(self) -> None:
        """Usage failures are their own class, never confused with a verdict."""
        with redirect_stdout(io.StringIO()), open(os.devnull, "w") as devnull:
            stderr, sys.stderr = sys.stderr, devnull
            try:
                code = check.run([], api=FakeApi(APPLICATION, {}, []), now=NOW)
            finally:
                sys.stderr = stderr
        self.assertEqual(code, check.EXIT_USAGE)

    def test_the_four_exit_codes_are_distinct(self) -> None:
        """Collapsing any two would defeat the alert rules that read them."""
        codes = [check.EXIT_OK, check.EXIT_UNDETERMINED, check.EXIT_USAGE, check.EXIT_DRIFT]
        self.assertEqual(len(set(codes)), 4)


class KubeApiTest(unittest.TestCase):
    """The reader's own guarantees."""

    def test_https_without_a_token_fails_loud(self) -> None:
        """An unverified or unauthenticated read is not a read."""
        api = check.KubeApi("https://kubernetes.default.svc", token_path="/nonexistent/token")
        with self.assertRaises(check.DeliverySyncError) as caught:
            api.get("/api/v1/namespaces/x/pods")
        self.assertIn("ServiceAccount token", str(caught.exception))

    def test_plain_http_needs_neither_token_nor_ca(self) -> None:
        """The `kubectl proxy` path an operator uses read-only."""
        seen = {}

        class Response:
            def __enter__(self):
                return io.StringIO(json.dumps({"items": []}))

            def __exit__(self, *args):
                return False

        def opener(request, timeout=None, context=None):
            seen["timeout"] = timeout
            seen["context"] = context
            seen["auth"] = request.get_header("Authorization")
            return Response()

        api = check.KubeApi("http://127.0.0.1:8001", open_url=opener)
        self.assertEqual(api.list_items("/api/v1/namespaces/x/pods"), [])
        self.assertEqual(seen["timeout"], check.HTTP_TIMEOUT_SECONDS)
        self.assertIsNone(seen["context"])
        self.assertIsNone(seen["auth"])

    def test_every_request_carries_an_explicit_timeout(self) -> None:
        """An unbounded default would hang the check instead of failing it."""
        self.assertIsInstance(check.HTTP_TIMEOUT_SECONDS, int)
        self.assertGreater(check.HTTP_TIMEOUT_SECONDS, 0)


if __name__ == "__main__":
    unittest.main(verbosity=2)
