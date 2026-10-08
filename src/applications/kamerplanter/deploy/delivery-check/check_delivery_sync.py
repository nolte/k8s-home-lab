#!/usr/bin/env python3
"""Ask the cluster whether ArgoCD actually applied the chart version it declares.

nolte/kamerplanter#1236 — the LAST hop of the delivery chain. A merge reaches
this cluster in four hops::

    merge -> docker-publish (GHCR) -> Renovate digest PR (chart pin) -> ArgoCD sync

Hop 3 has a watcher in the application repository. Hop 4 is measured from two
sides, and this file is the second one:

* ``scripts/ci/check_deployed_build.py`` in nolte/kamerplanter (#1318) asks a
  running instance whether it serves the build **its chart version** pins. It
  cannot see the case where ArgoCD never applied the *new* chart at all: the
  measured chart version is then the old one and everything is consistently
  old — clean, and wrong.
* This check supplies the missing operand: ``targetRevision`` from the ArgoCD
  ``Application``, compared against the chart version the **running workloads
  were actually rendered from**.

Together they bracket hop 4. Neither subsumes the other, and neither is run from
GitHub Actions, for a reason measured on 2026-09-01 and recorded in #1318: the
instance answers on an RFC1918 address and the repository has no self-hosted
runners, so a hosted runner would time out and a runner that *did* own that
subnet would silently measure a different machine.

WHAT IS COMPARED, AND WHAT IT CAN AND CANNOT SEE
------------------------------------------------
Three operands, all read from the Kubernetes API of the cluster the check runs
in. Nothing here talks to a registry, to git, or to the application.

**(D) declared** — ``Application.spec.sources[i].targetRevision`` for the source
that names a Helm chart. For the reference deployment that is ``0.2.1`` against
``oci://ghcr.io/nolte/charts/kamerplanter``. This is the operand #1318 has no
access to and the reason this check exists.

**(A) applied** — the ``helm.sh/chart`` label on the Deployments, StatefulSets
and DaemonSets that carry this Application's ArgoCD tracking annotation. Helm
writes it as ``<chart-name>-<chart-version>``; on the reference deployment the
workloads carry ``kamerplanter-0.2.1``. This is evidence about what reached the
**API server**, and it is deliberately *not* ArgoCD's own report:
``status.sync.status == "Synced"`` is ArgoCD grading its own homework, and the
2026-08-17 incident is precisely the shape where a green self-report and a stale
deployment coexist. ArgoCD's self-report is carried in the report as context and
never enters :func:`decide`.

**(R) running** — for every owned controller: ``observedGeneration`` against
``metadata.generation``, the updated/ready/available replica counts, a
Deployment's ``Progressing`` condition, a StatefulSet's
``currentRevision``/``updateRevision``; and for every pod those controllers
select, the digest in ``spec.containers[].image`` against the digest in
``status.containerStatuses[].imageID``. This is the operand that answers the
question ``Synced`` cannot: a rollout can be stuck, or a pod can sit on an older
ReplicaSet, while the Application is Synced and Healthy.

**Blind spots, stated rather than assumed.**

* A→R says nothing about whether the *chart* pins the right image; that is hop 3
  (``check_digest_freshness.py``) and #1318's comparison.
* D→A cannot see a change that ArgoCD has not yet been told about. If the
  repository declares ``0.2.2`` and the *live* ``Application`` object still says
  ``0.2.1``, this check compares 0.2.1 against 0.2.1 and reports ``match``. That
  gap belongs to the seed Application that renders this repository into the
  cluster, and it is a different hop from the one measured here.
* The image-digest comparison only fires for containers whose image reference is
  digest-pinned. An image pinned by a mutable tag has nothing to compare against
  and is reported as skipped, never as clean.
* ``helm.sh/chart`` names the chart version, not the chart *content*. Two
  publications of the same version would be indistinguishable here. Chart
  versions are immutable by convention in this delivery chain; a pre-release
  channel that is rewritten in place is not, and is flagged in the report.

THE THREE ANSWERS, NOT TWO
--------------------------
#1318 established a three-answer contract on the instance side and it is
load-bearing. The same contract holds here, on operand (A), because the same
failure is available: an answer that cannot be read is not the same as an answer
that says "wrong".

``no chart label on any owned workload``
    The workloads were not rendered by Helm, or were rendered by a chart that
    does not emit the standard label. **Nothing is wrong with the deployment** —
    but this check cannot run against it. Raises
    :class:`ChartVersionNotDisclosedError`: loud, exit
    :data:`EXIT_UNDETERMINED`, no report written, and a message naming the label
    rather than anything resembling drift. Measured example: the ``pihole``
    Application's Deployment carries the legacy ``chart`` label and no
    ``helm.sh/chart``. Reading a second label spelling by default would be the
    "two channels for one fact" drift class, so it is an explicit
    ``--chart-label`` opt-in and never a silent fallback.
``a label whose version part is empty or not a version``
    The label is there but says nothing comparable. Undetermined: loud, no
    verdict. Raises :class:`ChartVersionUnknownError`.
``an exact chart version``
    The only answer that reaches :func:`decide`.

The declared side (D) has the mirror-image failure and is resolved **first**, so
an unreadable applied side can be explained rather than merely reported:
``targetRevision`` must be a fixed version. ``main``, ``master``, ``HEAD``,
``*``, ``1.2.x``, ``>=1.2.0`` and a bare commit SHA are all resolved by ArgoCD at
sync time and name no single chart version, so they are undetermined, not drift.

Versions are compared as **exact strings**. There is deliberately no truncation
rule, no leading-``v`` normalisation and no semver-range resolution anywhere,
for the same reason #1318 has no truncation rule: each of them is a thing to get
wrong, and a comparison that quietly "fixes up" one side is a comparison that
can quietly agree with the wrong operand. Where two versions differ only by a
leading ``v``, the message says so — as a diagnosis for the operator, never as a
rule the comparison applies.

THE ANCHOR PROBLEM
------------------
#1318 samples the health endpoint three times because a Deployment mid-rollout
serves old and new pods behind one Service, so a single request lands on a
random replica. From inside the cluster that workaround is unnecessary and is
replaced by something strictly better: the check **enumerates every pod**, so a
split is observed deterministically rather than by chance. What is kept is the
property that made the sampling worth having — a split that survives the grace
window escalates to ``drift`` rather than being swallowed as ``rolling``, so a
*partial* hop-4 failure cannot hide behind "it is still rolling out".

The grace window is anchored on ``status.operationState.finishedAt``: the moment
ArgoCD last completed a sync. That is the right one-sided bound — the deployment
cannot have been behind before the apply that was supposed to fix it. When no
sync operation was ever recorded the weaker ``status.reconciledAt`` is used and
the report says so; when neither exists the verdict is undetermined rather than
assumed, exactly as #1318 refuses to guess a missing ``created`` timestamp.

Two conditions bypass the grace window entirely, because something more
authoritative than this check has already concluded:

* the last sync operation ``Failed``/``Error`` — ArgoCD says it did not apply;
* a Deployment whose ``Progressing`` condition reads ``ProgressDeadlineExceeded``
  — Kubernetes itself says the rollout is stuck.

HOW IT ALERTS
-------------
There is no operated notification path in this cluster. Measured on 2026-09-01:
Alertmanager runs, and every route in its generated configuration terminates in
the ``"null"`` receiver; ``argocd-notifications-controller`` runs with a stock
``argocd-notifications-cm`` carrying only ``argocdUrl: https://argocd.example.com``
— no triggers, no services, no templates. So nothing is *delivered* off-cluster,
and inventing a channel nobody operates would be worse than saying so.

What *is* operated is an observation path, and the check is built to land in it
without adding infrastructure: Prometheus scrapes kube-state-metrics, evaluates
35 rule groups, and selects ``PrometheusRule`` objects from **any** namespace
carrying ``release: monitoring`` (``ruleNamespaceSelector: {}``). kube-state-metrics
v2.18 exports ``kube_pod_container_status_last_terminated_exitcode``, so the exit
code below is a first-class time series — which means the three answer classes
stay distinguishable in the alert rules instead of collapsing into "the job
failed". The accompanying ``prometheusrule.yaml`` turns exit code 3 into a
``critical`` drift alert and exit codes 1 and 2 into a ``warning`` that states in
its own annotation that it is **not** drift.

FAIL LOUD
---------
An unreachable API server, an Application that does not exist, an ambiguous or
unreadable declared chart version, an Application that owns no workload, an
undisclosed or unreadable applied chart version, and a missing grace anchor are
all *undetermined*, not "no drift". Each raises, :func:`run` prints ``::error::``
and exits :data:`EXIT_UNDETERMINED` **without writing the report**, so a consumer
acting on the report cannot mistake an undetermined check for a clean one.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import ssl
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import Any

#: Every outbound call carries this explicitly; an unbounded default would let a
#: wedged API server hang the check instead of failing it.
HTTP_TIMEOUT_SECONDS = 30

#: Where a pod finds its own ServiceAccount credentials.
SERVICEACCOUNT_DIR = "/var/run/secrets/kubernetes.io/serviceaccount"

#: The standard Helm label. ``<chart-name>-<chart-version>``.
DEFAULT_CHART_LABEL = "helm.sh/chart"

#: The label Helm's own legacy templates used. Named only so the "not disclosed"
#: message can point at it; never read unless --chart-label asks for it.
LEGACY_CHART_LABEL = "chart"

#: ArgoCD's resource-tracking annotation, ``<app>:<group>/<Kind>:<ns>/<name>``.
TRACKING_ANNOTATION = "argocd.argoproj.io/tracking-id"

#: How long after ArgoCD's last completed sync a mismatch is still a rollout.
DEFAULT_GRACE_MINUTES = 60.0

#: A fixed chart version: the only declared value that can be compared. Anything
#: else is resolved by ArgoCD at sync time and names no single chart.
FIXED_VERSION_RE = re.compile(r"^v?\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.\-+]+)?$")

#: A version embedded somewhere inside a chart label's remainder. Used only to
#: tell "a longer chart name with its own version" from "this chart with an
#: uncomparable version", never to extract a version for comparison.
EMBEDDED_VERSION_RE = re.compile(r"-v?\d+\.\d+\.\d+")

#: ``sha256:<64 hex>`` anywhere in an image reference or an imageID.
IMAGE_DIGEST_RE = re.compile(r"sha256:[0-9a-f]{64}")

CONTROLLER_KINDS = (
    ("deployments", "Deployment"),
    ("statefulsets", "StatefulSet"),
    ("daemonsets", "DaemonSet"),
)

VERDICT_MATCH = "match"
VERDICT_WITHIN_GRACE = "within_grace"
VERDICT_ROLLING = "rolling"
VERDICT_DRIFT = "drift"

EXIT_OK = 0
EXIT_UNDETERMINED = 1
EXIT_USAGE = 2
EXIT_DRIFT = 3

#: ``urllib.request.urlopen``-shaped; the single injection seam for every read.
Opener = Callable[..., Any]


class DeliverySyncError(RuntimeError):
    """A condition under which the verdict could not be determined — fail loud."""


class ChartVersionNotDisclosedError(DeliverySyncError):
    """No owned workload carries a readable chart label.

    Deliberately its own type: this says **nothing** about whether the
    deployment is current, and its message must not read like drift.
    """


class ChartVersionUnknownError(DeliverySyncError):
    """A chart label is present but its version part is not comparable."""


@dataclass(frozen=True)
class Declared:
    """The chart version the ArgoCD Application declares.

    Attributes:
        chart_name: Name of the chart, from ``source.chart`` or the last segment
            of an ``oci://`` repository URL.
        version: ``targetRevision``, verified to be a fixed version.
        repo_url: The source's repository URL, for the report.
        source_index: Which entry of ``spec.sources`` was selected.
        prerelease: Whether the version carries a pre-release suffix. Such a
            channel may be rewritten in place, which weakens the immutability
            this comparison otherwise relies on.
    """

    chart_name: str
    version: str
    repo_url: str
    source_index: int
    prerelease: bool


@dataclass(frozen=True)
class Controller:
    """One owned Deployment, StatefulSet or DaemonSet."""

    kind: str
    name: str
    chart_label: str | None
    chart_version: str | None
    generation: int
    observed_generation: int | None
    selector: dict[str, str] | None
    selector_readable: bool
    status: dict[str, Any]
    conditions: list[dict[str, Any]]


@dataclass(frozen=True)
class Finding:
    """One reason the deployment is not demonstrably current.

    Attributes:
        kind: Machine-readable class of the finding.
        message: The sentence an operator reads.
        conclusive: Whether a more authoritative component (ArgoCD, Kubernetes)
            has already declared this a failure. Conclusive findings bypass the
            grace window; nothing else does.
        never_softened: Whether the grace window may downgrade this to
            ``rolling``. A split applied-version set is never softened past the
            window — that is the property #1318's sampling exists to protect.
    """

    kind: str
    message: str
    conclusive: bool = False
    never_softened: bool = False


@dataclass(frozen=True)
class Verdict:
    """The determined outcome and the sentence that explains it."""

    name: str
    headline: str
    detail: str = ""

    @property
    def is_alert(self) -> bool:
        """Whether this verdict is the incident hop 4 exists to surface."""
        return self.name == VERDICT_DRIFT


@dataclass
class ArgoState:
    """ArgoCD's own report about the Application.

    Carried into the report as context and — apart from the two conclusive
    signals named in the module docstring — deliberately kept out of
    :func:`decide`. A green self-report coexisting with a stale deployment is
    the incident this check exists to catch.
    """

    sync_status: str | None = None
    health_status: str | None = None
    operation_phase: str | None = None
    operation_finished_at: str | None = None
    operation_message: str | None = None
    reconciled_at: str | None = None
    compared_to_revisions: list[str] = field(default_factory=list)


class KubeApi:
    """The slice of the Kubernetes API this check reads.

    Every request is a GET, carries an explicit timeout, and verifies TLS
    against the cluster CA. The ServiceAccount token is re-read per request
    because a projected token is rotated underneath a long-lived process.
    """

    def __init__(
        self,
        api_server: str,
        *,
        token_path: str = f"{SERVICEACCOUNT_DIR}/token",
        ca_path: str = f"{SERVICEACCOUNT_DIR}/ca.crt",
        open_url: Opener = urllib.request.urlopen,
    ) -> None:
        """Bind the reader to one API server.

        Args:
            api_server: Base URL, e.g. ``https://kubernetes.default.svc``. A
                plain-http URL (``kubectl proxy``) is accepted and then carries
                neither token nor CA — that is the read-only operator path.
            token_path: Where the ServiceAccount token lives.
            ca_path: Where the cluster CA bundle lives.
            open_url: Injection seam for ``urllib.request.urlopen``.
        """
        self._base = api_server.rstrip("/")
        self._token_path = token_path
        self._ca_path = ca_path
        self._open_url = open_url
        self._secure = urllib.parse.urlsplit(self._base).scheme == "https"
        self._context: ssl.SSLContext | None = None

    def _ssl_context(self) -> ssl.SSLContext | None:
        """Build the TLS context, verifying against the cluster CA.

        Returns:
            The context for an https API server, or None for plain http.

        Raises:
            DeliverySyncError: When the CA bundle is missing or unusable.
                Verification is never disabled to work around it.
        """
        if not self._secure:
            return None
        if self._context is None:
            try:
                self._context = ssl.create_default_context(cafile=self._ca_path)
            except (OSError, ssl.SSLError) as exc:
                raise DeliverySyncError(
                    f"cannot build a TLS context from {self._ca_path}: {exc}. Refusing to fall back to "
                    "an unverified connection — an unverified read of the API server is not a read."
                ) from exc
        return self._context

    def _token(self) -> str | None:
        """Read the ServiceAccount token, if this client needs one.

        Returns:
            The bearer token, or None when talking plain http.

        Raises:
            DeliverySyncError: When an https client has no readable token.
        """
        if not self._secure:
            return None
        try:
            with open(self._token_path, encoding="utf-8") as handle:
                return handle.read().strip()
        except OSError as exc:
            raise DeliverySyncError(
                f"no ServiceAccount token at {self._token_path}: {exc}. Inside the cluster this file is "
                "mounted automatically; outside it, point --api-server at a `kubectl proxy` instead."
            ) from exc

    def get(self, path: str) -> dict:
        """GET one API path and decode the JSON body.

        Args:
            path: Absolute API path, e.g. ``/api/v1/namespaces/x/pods``.

        Returns:
            The decoded response.

        Raises:
            DeliverySyncError: On any transport, status or decode failure.
        """
        url = f"{self._base}{path}"
        request = urllib.request.Request(url)
        request.add_header("Accept", "application/json")
        token = self._token()
        if token:
            request.add_header("Authorization", f"Bearer {token}")
        try:
            with self._open_url(request, timeout=HTTP_TIMEOUT_SECONDS, context=self._ssl_context()) as response:
                return json.load(response)
        except urllib.error.HTTPError as exc:
            raise DeliverySyncError(f"GET {path} answered HTTP {exc.code}") from exc
        except (urllib.error.URLError, TimeoutError, ssl.SSLError) as exc:
            raise DeliverySyncError(f"GET {path} failed: {exc}") from exc
        except json.JSONDecodeError as exc:
            raise DeliverySyncError(f"GET {path} did not answer with JSON: {exc}") from exc

    def application(self, namespace: str, name: str) -> dict:
        """Read one ArgoCD Application.

        Args:
            namespace: Namespace the Application object lives in.
            name: Application name.

        Returns:
            The decoded Application.
        """
        return self.get(f"/apis/argoproj.io/v1alpha1/namespaces/{namespace}/applications/{name}")

    def list_items(self, path: str) -> list[dict]:
        """GET a list endpoint and return its items.

        Args:
            path: Absolute API path of a list endpoint.

        Returns:
            The ``items`` array, or an empty list when absent.
        """
        return list(self.get(path).get("items") or [])


def parse_timestamp(value: str) -> datetime:
    """Parse an RFC3339 timestamp into an aware UTC datetime.

    Args:
        value: The timestamp as the API server writes it.

    Returns:
        A timezone-aware datetime.

    Raises:
        DeliverySyncError: When the value cannot be parsed.
    """
    normalised = value.replace("Z", "+00:00")
    # Defend against more than six fractional digits, which fromisoformat
    # rejects and some writers emit.
    normalised = re.sub(r"(\.\d{6})\d+", r"\1", normalised)
    try:
        parsed = datetime.fromisoformat(normalised)
    except ValueError as exc:
        raise DeliverySyncError(f"unparseable timestamp {value!r}: {exc}") from exc
    return parsed if parsed.tzinfo else parsed.replace(tzinfo=UTC)


def _sources(application: dict) -> list[dict]:
    """Return the Application's sources, single- or multi-source alike.

    Args:
        application: The decoded Application.

    Returns:
        Every source entry, in declaration order.
    """
    spec = application.get("spec") or {}
    sources = spec.get("sources")
    if isinstance(sources, list) and sources:
        return [entry for entry in sources if isinstance(entry, dict)]
    single = spec.get("source")
    return [single] if isinstance(single, dict) else []


def _chart_name_of(source: dict) -> str | None:
    """Derive the Helm chart name a source names, if it names one.

    Two shapes carry a chart: a classic repository source with ``chart:``, and
    an OCI source whose ``repoURL`` ends in the chart name.

    Args:
        source: One entry of ``spec.sources``.

    Returns:
        The chart name, or None when the source is not a Helm chart source.
    """
    chart = str(source.get("chart") or "").strip()
    if chart:
        return chart
    repo_url = str(source.get("repoURL") or "").strip()
    if not repo_url.startswith("oci://"):
        return None
    segments = [segment for segment in urllib.parse.urlsplit(repo_url).path.split("/") if segment]
    if not segments:
        # `oci://ghcr.io` with no path names no chart; saying so beats guessing.
        return None
    return segments[-1]


def resolve_declared(application: dict, *, source_index: int | None, chart_name: str | None) -> Declared:
    """Resolve the chart version the Application declares.

    Resolved before anything is read about the running workloads, so that an
    unreadable applied side can be *explained* rather than merely reported.

    Args:
        application: The decoded Application.
        source_index: Explicit ``spec.sources`` index, or None to select
            automatically.
        chart_name: Explicit chart name override, or None to derive it.

    Returns:
        The declared chart version.

    Raises:
        DeliverySyncError: When no source, more than one candidate source, a
            non-fixed ``targetRevision`` or an underivable chart name leaves the
            declared side uncomparable. None of these is drift.
    """
    sources = _sources(application)
    if not sources:
        raise DeliverySyncError("the Application declares no source at all; there is nothing to compare against")

    if source_index is not None:
        if not 0 <= source_index < len(sources):
            raise DeliverySyncError(
                f"--source-index {source_index} is out of range: the Application declares {len(sources)} source(s)"
            )
        selected, index = sources[source_index], source_index
    else:
        candidates = [(position, entry) for position, entry in enumerate(sources) if _chart_name_of(entry)]
        if not candidates:
            raise DeliverySyncError(
                "no source of this Application names a Helm chart (neither a `chart:` field nor an "
                "`oci://` repoURL), so it declares no chart version. This check compares chart "
                "versions and cannot run here; it says nothing about whether the deployment is current."
            )
        if len(candidates) > 1:
            named = ", ".join(f"[{position}] {_chart_name_of(entry)}" for position, entry in candidates)
            raise DeliverySyncError(
                f"{len(candidates)} sources name a Helm chart ({named}). There is no single declared "
                "chart version; pass --source-index to say which one this check should measure."
            )
        index, selected = candidates[0]

    revision = str(selected.get("targetRevision") or "").strip()
    if not revision:
        raise DeliverySyncError(
            f"source [{index}] declares no targetRevision, so ArgoCD resolves the version at sync time "
            "and there is no declared version to compare."
        )
    if not FIXED_VERSION_RE.match(revision):
        raise DeliverySyncError(
            f"source [{index}] declares targetRevision {revision!r}, which is not a fixed chart version. "
            "A branch, tag range, `*`, `1.2.x`, `>=1.2.0` or a bare commit is resolved by ArgoCD at sync "
            "time and names no single chart version, so this comparison is undetermined — NOT drift. "
            "Pin the source to an exact version, or point --source-index at the source that is pinned."
        )

    resolved_name = (chart_name or "").strip() or _chart_name_of(selected)
    if not resolved_name:
        raise DeliverySyncError(
            f"source [{index}] declares targetRevision {revision!r} but names no Helm chart, so the "
            "`helm.sh/chart` label on the workloads has no chart name to be matched against. Pass "
            "--chart-name if you know it."
        )

    return Declared(
        chart_name=resolved_name,
        version=revision,
        repo_url=str(selected.get("repoURL") or ""),
        source_index=index,
        prerelease="-" in revision,
    )


def read_argo_state(application: dict) -> ArgoState:
    """Collect ArgoCD's own report about the Application.

    Args:
        application: The decoded Application.

    Returns:
        The self-report, for the record and for the two conclusive signals.
    """
    status = application.get("status") or {}
    operation = status.get("operationState") or {}
    compared_to = (status.get("sync") or {}).get("comparedTo") or {}
    compared_sources = compared_to.get("sources") or ([compared_to["source"]] if "source" in compared_to else [])
    return ArgoState(
        sync_status=(status.get("sync") or {}).get("status"),
        health_status=(status.get("health") or {}).get("status"),
        operation_phase=operation.get("phase"),
        operation_finished_at=operation.get("finishedAt"),
        operation_message=operation.get("message"),
        reconciled_at=status.get("reconciledAt"),
        compared_to_revisions=[
            str(entry.get("targetRevision") or "") for entry in compared_sources if isinstance(entry, dict)
        ],
    )


def _owned(resource: dict, application_name: str) -> bool:
    """Whether ArgoCD tracks this resource as part of the Application.

    The tracking annotation is authoritative and unambiguous. A label fallback
    is deliberately absent: ``app.kubernetes.io/instance`` is the Helm release
    name, which merely happens to coincide with the Application name here, and
    guessing ownership is how a check ends up measuring the wrong workloads.

    Args:
        resource: A decoded Kubernetes object.
        application_name: The Application whose resources are wanted.

    Returns:
        Whether the resource is tracked by that Application.
    """
    annotations = (resource.get("metadata") or {}).get("annotations") or {}
    return str(annotations.get(TRACKING_ANNOTATION) or "").startswith(f"{application_name}:")


def _chart_version_from_label(label_value: str, chart_name: str) -> str | None:
    """Extract the chart version from a ``<chart-name>-<version>`` label.

    Matching is anchored on the *known* chart name rather than on a split, so a
    subchart (``valkey-0.10.0`` beside ``kamerplanter-0.2.1`` on the reference
    deployment) and a pre-release version containing its own hyphens are both
    handled without a heuristic.

    Args:
        label_value: The raw label value.
        chart_name: The chart name the Application declares.

    Returns:
        The version part when the label names *this* chart, else None.
    """
    prefix = f"{chart_name}-"
    if not label_value.startswith(prefix):
        return None
    remainder = label_value[len(prefix) :]
    # Helm replaces `+` with `_` in the label, so accept that spelling too.
    return remainder if FIXED_VERSION_RE.match(remainder.replace("_", "+")) else None


def read_controllers(api: KubeApi, namespace: str, application_name: str, chart_label: str) -> list[Controller]:
    """Read every controller in the namespace that this Application owns.

    Args:
        api: Reader bound to the cluster.
        namespace: The Application's destination namespace.
        application_name: The Application whose resources are wanted.
        chart_label: The label key that carries the chart version.

    Returns:
        Every owned Deployment, StatefulSet and DaemonSet.

    Raises:
        DeliverySyncError: When the Application owns no controller at all.
    """
    controllers: list[Controller] = []
    for plural, kind in CONTROLLER_KINDS:
        for item in api.list_items(f"/apis/apps/v1/namespaces/{namespace}/{plural}"):
            if not _owned(item, application_name):
                continue
            metadata = item.get("metadata") or {}
            labels = metadata.get("labels") or {}
            raw_label = labels.get(chart_label)
            selector = ((item.get("spec") or {}).get("selector") or {}).get("matchLabels")
            controllers.append(
                Controller(
                    kind=kind,
                    name=str(metadata.get("name") or ""),
                    chart_label=str(raw_label) if raw_label is not None else None,
                    chart_version=None,
                    generation=int(metadata.get("generation") or 0),
                    observed_generation=(item.get("status") or {}).get("observedGeneration"),
                    selector=dict(selector) if isinstance(selector, dict) and selector else None,
                    selector_readable=isinstance(selector, dict) and bool(selector),
                    status=dict(item.get("status") or {}),
                    conditions=list((item.get("status") or {}).get("conditions") or []),
                )
            )
    if not controllers:
        raise DeliverySyncError(
            f"Application {application_name!r} owns no Deployment, StatefulSet or DaemonSet in namespace "
            f"{namespace!r} (looked for the {TRACKING_ANNOTATION} annotation). There is nothing running "
            "to compare the declared chart version against, so the verdict is undetermined."
        )
    return controllers


def applied_versions(controllers: list[Controller], declared: Declared, chart_label: str) -> dict[str, list[str]]:
    """Partition the owned controllers by what their chart label says.

    Args:
        controllers: Every owned controller.
        declared: The declared chart version, for its chart name.
        chart_label: The label key that was read.

    Returns:
        A mapping from chart version to the controllers reporting it. The
        controllers that report nothing comparable are reachable through the
        raised errors rather than being silently dropped.

    Raises:
        ChartVersionNotDisclosedError: When no owned controller carries a label
            naming the declared chart. This is not drift.
        ChartVersionUnknownError: When labels name the chart but carry no
            comparable version.
    """
    by_version: dict[str, list[str]] = {}
    other_charts: list[str] = []
    unlabelled: list[str] = []
    unparseable: list[str] = []

    for controller in controllers:
        reference = f"{controller.kind}/{controller.name}"
        if controller.chart_label is None:
            unlabelled.append(reference)
            continue
        version = _chart_version_from_label(controller.chart_label, declared.chart_name)
        if version is None:
            # Which of the two "cannot compare" messages fits. Starting with the
            # chart name is not enough: a subchart called `<chart>-exporter`
            # emits `<chart>-exporter-1.0.0`, whose remainder carries a version
            # of its own and therefore names a DIFFERENT chart. A remainder with
            # no version anywhere in it (`<chart>-latest`) is this chart with a
            # version that cannot be compared. Both are RED with no drift alert,
            # so this only decides which sentence the operator reads — it is not
            # load-bearing for the contract.
            remainder = controller.chart_label[len(declared.chart_name) + 1 :]
            names_another_chart = not controller.chart_label.startswith(f"{declared.chart_name}-") or bool(
                EMBEDDED_VERSION_RE.search(remainder)
            )
            bucket = other_charts if names_another_chart else unparseable
            bucket.append(f"{reference} ({controller.chart_label})")
            continue
        by_version.setdefault(version, []).append(reference)

    if by_version:
        return by_version

    if unparseable:
        raise ChartVersionUnknownError(
            f"every owned controller that names chart {declared.chart_name!r} carries a {chart_label} "
            f"value whose version part is not a version: {', '.join(unparseable)}. The label is there "
            "but says nothing comparable, so the measurement is undetermined — NOT drift."
        )

    if other_charts and not unlabelled:
        raise ChartVersionNotDisclosedError(
            f"no owned controller carries a {chart_label} naming chart {declared.chart_name!r}; the ones "
            f"that are labelled name other charts: {', '.join(other_charts)}. The Application declares "
            f"{declared.chart_name}-{declared.version}, so either --chart-name is wrong or this "
            "Application renders only subcharts. This is NOT drift and says nothing about whether the "
            "deployment is current."
        )

    raise ChartVersionNotDisclosedError(
        f"no owned controller carries a {chart_label} label ({', '.join(unlabelled + other_charts)}). "
        "Only Helm-rendered resources carry it, and not every chart emits it — the deployment may be "
        "perfectly current, and nothing here says otherwise. This check simply cannot run against it. "
        f"Some charts write the legacy {LEGACY_CHART_LABEL!r} label instead; reading a second spelling "
        f"by default would be two channels for one fact, so pass --chart-label {LEGACY_CHART_LABEL} "
        "explicitly if you have verified it means the same thing here."
    )


def _int(value: Any) -> int:
    """Coerce an optional status counter to an int.

    Args:
        value: The raw status field, possibly absent.

    Returns:
        The integer value, or 0 when absent or not a number.
    """
    return value if isinstance(value, int) and not isinstance(value, bool) else 0


def _condition(controller: Controller, condition_type: str) -> dict[str, Any] | None:
    """Find one status condition by type.

    Args:
        controller: The controller to inspect.
        condition_type: The ``type`` to look for.

    Returns:
        The condition, or None when absent.
    """
    for condition in controller.conditions:
        if isinstance(condition, dict) and condition.get("type") == condition_type:
            return condition
    return None


def rollout_findings(controllers: list[Controller]) -> list[Finding]:
    """Check whether every owned controller has finished rolling out.

    This is the operand ``status.sync.status == "Synced"`` cannot supply. ArgoCD
    reports Synced as soon as the *manifests* match; whether the pods followed is
    a separate fact, and the one the 2026-08-17 incident turned on.

    Args:
        controllers: Every owned controller.

    Returns:
        One finding per controller that has not fully rolled out.
    """
    findings: list[Finding] = []
    for controller in controllers:
        reference = f"{controller.kind}/{controller.name}"

        if controller.observed_generation is None:
            findings.append(
                Finding(
                    "observed_generation_missing",
                    f"{reference} reports no status.observedGeneration, so whether its controller has "
                    "even seen the applied spec cannot be determined.",
                )
            )
        elif controller.observed_generation < controller.generation:
            findings.append(
                Finding(
                    "generation_not_observed",
                    f"{reference} is at generation {controller.generation} but its controller has only "
                    f"observed {controller.observed_generation}: the applied spec has not been acted on.",
                )
            )

        progressing = _condition(controller, "Progressing")
        if progressing and progressing.get("reason") == "ProgressDeadlineExceeded":
            findings.append(
                Finding(
                    "progress_deadline_exceeded",
                    f"{reference} reports Progressing=ProgressDeadlineExceeded: Kubernetes itself has "
                    "declared this rollout stuck, so no grace window applies.",
                    conclusive=True,
                )
            )

        if controller.kind == "DaemonSet":
            desired = _int(controller.status.get("desiredNumberScheduled"))
            updated = _int(controller.status.get("updatedNumberScheduled"))
            ready = _int(controller.status.get("numberReady"))
            available = _int(controller.status.get("numberAvailable"))
            if desired and not (updated == ready == available == desired):
                findings.append(
                    Finding(
                        "rollout_incomplete",
                        f"{reference} wants {desired} node(s) but has updated={updated} ready={ready} "
                        f"available={available}.",
                    )
                )
            continue

        desired = _int(controller.status.get("replicas"))
        updated = _int(controller.status.get("updatedReplicas"))
        ready = _int(controller.status.get("readyReplicas"))
        available = _int(controller.status.get("availableReplicas"))
        if desired and not (updated == ready == available == desired):
            findings.append(
                Finding(
                    "rollout_incomplete",
                    f"{reference} wants {desired} replica(s) but has updated={updated} ready={ready} "
                    f"available={available}: some pods do not yet run the applied spec.",
                )
            )

        if controller.kind == "StatefulSet":
            current = str(controller.status.get("currentRevision") or "")
            update = str(controller.status.get("updateRevision") or "")
            if current and update and current != update:
                findings.append(
                    Finding(
                        "statefulset_revision_split",
                        f"{reference} is split between revisions {current} and {update}: the pods have "
                        "not all been recreated from the applied spec.",
                        never_softened=True,
                    )
                )
    return findings


def _selects(pod: dict, selector: dict[str, str]) -> bool:
    """Whether a pod carries every label of a controller's matchLabels selector.

    Args:
        pod: The decoded pod.
        selector: The controller's ``spec.selector.matchLabels``.

    Returns:
        Whether the pod belongs to that controller.
    """
    labels = (pod.get("metadata") or {}).get("labels") or {}
    return all(labels.get(key) == value for key, value in selector.items())


def image_findings(controllers: list[Controller], pods: list[dict]) -> tuple[list[Finding], list[str]]:
    """Check that every running container serves the digest its spec pins.

    A pod's ``spec.containers[].image`` is the reference its ReplicaSet template
    carries — on this delivery chain a ``<tag>@sha256:<digest>`` pin written by
    the chart. ``status.containerStatuses[].imageID`` is the digest the kubelet
    actually resolved. A divergence is the #1024 failure: a node serving a
    cached image for a reference the chart believes is content-addressed.

    Args:
        controllers: Every owned controller.
        pods: Every pod in the destination namespace.

    Returns:
        ``(findings, skipped)`` — the mismatches, and human-readable notes about
        every container that could not be compared. Skipped containers are
        reported rather than silently counted as clean.
    """
    findings: list[Finding] = []
    skipped: list[str] = []

    for controller in controllers:
        reference = f"{controller.kind}/{controller.name}"
        if not controller.selector_readable or controller.selector is None:
            skipped.append(f"{reference}: no matchLabels selector, so its pods cannot be identified here")
            continue
        selected = [pod for pod in pods if _selects(pod, controller.selector)]
        if not selected:
            skipped.append(f"{reference}: selects no pod right now")
            continue
        for pod in selected:
            pod_name = (pod.get("metadata") or {}).get("name") or "<unnamed>"
            statuses = {
                str(entry.get("name")): entry for entry in ((pod.get("status") or {}).get("containerStatuses") or [])
            }
            for container in (pod.get("spec") or {}).get("containers") or []:
                container_name = str(container.get("name") or "")
                image = str(container.get("image") or "")
                pinned = IMAGE_DIGEST_RE.search(image)
                if not pinned:
                    skipped.append(f"{pod_name}/{container_name}: image {image!r} is not digest-pinned")
                    continue
                status = statuses.get(container_name)
                if not status or not status.get("imageID"):
                    skipped.append(f"{pod_name}/{container_name}: reports no imageID yet")
                    continue
                running = IMAGE_DIGEST_RE.search(str(status["imageID"]))
                if not running:
                    skipped.append(f"{pod_name}/{container_name}: imageID {status['imageID']!r} carries no digest")
                    continue
                if running.group(0) != pinned.group(0):
                    findings.append(
                        Finding(
                            "image_digest_mismatch",
                            f"{pod_name}/{container_name} was told to run {pinned.group(0)} but is running "
                            f"{running.group(0)}. The digest is content-addressed, so these are different "
                            "bytes: the node served something other than what the chart pinned.",
                            conclusive=True,
                        )
                    )
    return findings, skipped


def grace_anchor(argo: ArgoState) -> tuple[datetime, str]:
    """Pick the moment the grace window is measured from.

    Args:
        argo: ArgoCD's self-report.

    Returns:
        ``(moment, description)`` — the anchor and what it is.

    Raises:
        DeliverySyncError: When neither a completed sync nor a reconciliation
            timestamp exists. A missing anchor is undetermined, not assumed.
    """
    if argo.operation_finished_at:
        return parse_timestamp(argo.operation_finished_at), f"last sync finished at {argo.operation_finished_at}"
    if argo.reconciled_at:
        return (
            parse_timestamp(argo.reconciled_at),
            f"last reconciliation at {argo.reconciled_at} (weaker anchor: no sync operation was recorded)",
        )
    raise DeliverySyncError(
        "the Application records neither status.operationState.finishedAt nor status.reconciledAt, so the "
        "grace window has no anchor. The verdict is undetermined rather than assumed."
    )


def decide(
    declared: Declared,
    by_version: dict[str, list[str]],
    findings: list[Finding],
    argo: ArgoState,
    *,
    now: datetime,
    grace_minutes: float,
) -> tuple[Verdict, list[Finding]]:
    """Turn the declared version, the applied versions and the findings into one verdict.

    Args:
        declared: The chart version the Application declares.
        by_version: Applied chart version to the controllers reporting it.
        findings: Rollout and image findings, in discovery order.
        argo: ArgoCD's self-report, for its two conclusive signals and the anchor.
        now: Measurement time.
        grace_minutes: How long after the anchor a non-conclusive finding is
            still an in-progress rollout rather than an alert.

    Returns:
        ``(verdict, findings)`` — the verdict and the COMPLETE finding list,
        including the comparison findings composed here. Returning them is not
        cosmetic: a report carrying only the caller's findings would show a
        ``drift`` verdict beside an empty ``findings`` array, and a report that
        cannot say why is the shape this whole exercise exists to avoid.

    Raises:
        DeliverySyncError: When there is nothing to decide on, or no anchor.
    """
    if not by_version:
        raise DeliverySyncError("no applied chart version was read; refusing to decide on nothing")

    all_findings = list(findings)
    applied = sorted(by_version)

    if applied != [declared.version]:
        if len(applied) > 1:
            all_findings.insert(
                0,
                Finding(
                    "applied_version_split",
                    f"the owned workloads were rendered from {len(applied)} different chart versions "
                    f"({', '.join(applied)}) while the Application declares {declared.version}: "
                    + "; ".join(f"{version} -> {', '.join(by_version[version])}" for version in applied)
                    + ". A split apply is never softened to `rolling` once the grace window has passed — "
                    "letting it be would give this check a permanent blind spot in a partial hop-4 failure.",
                    never_softened=True,
                ),
            )
        else:
            hint = ""
            if applied[0].lstrip("v") == declared.version.lstrip("v"):
                hint = (
                    " The two differ only by a leading 'v'; this check compares exactly and has no "
                    "normalisation rule, deliberately."
                )
            all_findings.insert(
                0,
                Finding(
                    "declared_version_not_applied",
                    f"the Application declares chart {declared.chart_name} {declared.version} but its "
                    f"workloads were rendered from {applied[0]} ({', '.join(by_version[applied[0]])})."
                    + hint,
                ),
            )

    if argo.operation_phase in ("Failed", "Error"):
        all_findings.append(
            Finding(
                "sync_operation_failed",
                f"ArgoCD's last sync operation ended {argo.operation_phase}"
                + (f": {argo.operation_message}" if argo.operation_message else "")
                + ". ArgoCD itself says it did not apply the declared state, so no grace window applies.",
                conclusive=True,
            )
        )

    if not all_findings:
        return (
            Verdict(
                VERDICT_MATCH,
                f"chart {declared.chart_name} {declared.version} is declared, applied and fully rolled out "
                f"across {sum(len(names) for names in by_version.values())} controller(s).",
            ),
            all_findings,
        )

    summary = " ".join(finding.message for finding in all_findings)

    if argo.operation_phase == "Running":
        return (
            Verdict(
                VERDICT_ROLLING,
                f"a sync operation is in progress; {len(all_findings)} finding(s) are expected while it runs.",
                summary,
            ),
            all_findings,
        )

    anchor, anchor_description = grace_anchor(argo)
    age_minutes = (now - anchor).total_seconds() / 60.0
    conclusive = [finding for finding in all_findings if finding.conclusive]
    unsoftenable = [finding for finding in all_findings if finding.never_softened]

    if conclusive:
        return (
            Verdict(
                VERDICT_DRIFT,
                f"{len(conclusive)} finding(s) are conclusive — a component more authoritative than this "
                "check has already declared the delivery failed.",
                summary,
            ),
            all_findings,
        )

    if age_minutes < grace_minutes and not unsoftenable:
        rolling = all(finding.kind in ("rollout_incomplete", "generation_not_observed") for finding in all_findings)
        return (
            Verdict(
                VERDICT_ROLLING if rolling else VERDICT_WITHIN_GRACE,
                f"{len(all_findings)} finding(s), but the {anchor_description} was only {age_minutes:.0f} "
                f"minute(s) ago (< {grace_minutes:.0f}).",
                summary + " Re-run once the rollout settles.",
            ),
            all_findings,
        )

    return (
        Verdict(
            VERDICT_DRIFT,
            f"hop 4 has failed: {len(all_findings)} finding(s) {age_minutes / 60.0:.1f} hour(s) after the "
            f"{anchor_description}.",
            summary
            + " The anchor is an UPPER bound on how long the cluster has been behind — it cannot have been "
            "behind before the apply that was supposed to fix it.",
        ),
        all_findings,
    )


def build_report(
    declared: Declared,
    by_version: dict[str, list[str]],
    findings: list[Finding],
    skipped: list[str],
    verdict: Verdict,
    argo: ArgoState,
    *,
    application: str,
    namespace: str,
    chart_label: str,
    grace_minutes: float,
    now: datetime,
) -> dict:
    """Assemble the machine-readable report.

    Args:
        declared: The declared chart version.
        by_version: Applied chart version to the controllers reporting it.
        findings: Every finding, in discovery order.
        skipped: Notes about containers that could not be compared.
        verdict: The determined verdict.
        argo: ArgoCD's self-report.
        application: Application name.
        namespace: Destination namespace.
        chart_label: The label key that was read.
        grace_minutes: The window that was applied.
        now: Measurement time.

    Returns:
        The report, shaped like the sibling watchers' ``*-report.json``.
    """
    return {
        "verdict": verdict.name,
        "headline": verdict.headline,
        "detail": verdict.detail,
        "measured_at": now.isoformat(),
        "application": application,
        "namespace": namespace,
        "declared": {
            "chart_name": declared.chart_name,
            "version": declared.version,
            "repo_url": declared.repo_url,
            "source_index": declared.source_index,
            "prerelease": declared.prerelease,
        },
        "applied": {
            "chart_label": chart_label,
            "versions": {version: sorted(names) for version, names in sorted(by_version.items())},
        },
        "findings": [{"kind": finding.kind, "message": finding.message} for finding in findings],
        "not_compared": skipped,
        # ArgoCD's own report. Recorded so a verdict can be argued about later,
        # and deliberately not the operand: a green self-report beside a stale
        # deployment is the incident, not the absence of one.
        "argocd_self_report": {
            "sync_status": argo.sync_status,
            "health_status": argo.health_status,
            "operation_phase": argo.operation_phase,
            "operation_finished_at": argo.operation_finished_at,
            "reconciled_at": argo.reconciled_at,
            "compared_to_revisions": argo.compared_to_revisions,
        },
        "grace_minutes": grace_minutes,
    }


def default_api_server() -> str:
    """Derive the in-cluster API server URL from the injected environment.

    Returns:
        The API server base URL.
    """
    host = os.environ.get("KUBERNETES_SERVICE_HOST")
    port = os.environ.get("KUBERNETES_SERVICE_PORT_HTTPS") or os.environ.get("KUBERNETES_SERVICE_PORT") or "443"
    return f"https://{host}:{port}" if host else "https://kubernetes.default.svc"


def _parser() -> argparse.ArgumentParser:
    """Build the command-line parser.

    Returns:
        The parser.
    """
    parser = argparse.ArgumentParser(
        prog="check_delivery_sync.py",
        description=(
            "Check whether ArgoCD applied the chart version its Application declares, and whether that "
            "chart actually reached every pod (nolte/kamerplanter#1236, hop 4)."
        ),
    )
    parser.add_argument("--application", required=True, help="Name of the ArgoCD Application to measure.")
    parser.add_argument(
        "--argocd-namespace",
        default="argocd",
        help="Namespace the Application object lives in (default: argocd).",
    )
    parser.add_argument(
        "--namespace",
        help="Destination namespace override; by default spec.destination.namespace is used.",
    )
    parser.add_argument(
        "--source-index",
        type=int,
        help="Which spec.sources entry declares the chart. Only needed when several name a chart.",
    )
    parser.add_argument("--chart-name", help="Chart name override; by default it is derived from the source.")
    parser.add_argument(
        "--chart-label",
        default=DEFAULT_CHART_LABEL,
        help=(
            f"Label key carrying `<chart>-<version>` (default: {DEFAULT_CHART_LABEL}). Pass "
            f"`{LEGACY_CHART_LABEL}` only for a chart you have verified uses the legacy spelling."
        ),
    )
    parser.add_argument(
        "--grace-minutes",
        type=float,
        default=DEFAULT_GRACE_MINUTES,
        help=f"Grace window, anchored on ArgoCD's last completed sync (default {DEFAULT_GRACE_MINUTES:.0f}).",
    )
    parser.add_argument(
        "--api-server",
        default=default_api_server(),
        help="Kubernetes API base URL. A plain-http URL (a `kubectl proxy`) needs no token and no CA.",
    )
    parser.add_argument("--json", dest="json_path", help="Write the report here, only on a determined verdict.")
    return parser


def main(
    argv: list[str] | None = None,
    *,
    api: KubeApi | None = None,
    open_url: Opener = urllib.request.urlopen,
    now: datetime | None = None,
) -> int:
    """Run the check and, on a determined verdict, write the report.

    Args:
        argv: Command line without the program name.
        api: A pre-built reader, for tests.
        open_url: Injection seam for every network read.
        now: Measurement time, defaulting to the current UTC time.

    Returns:
        :data:`EXIT_OK` for match/within_grace/rolling, :data:`EXIT_DRIFT` for
        the incident.

    Raises:
        DeliverySyncError: On anything that leaves the verdict undetermined.
    """
    args = _parser().parse_args(sys.argv[1:] if argv is None else argv)
    moment = now or datetime.now(UTC)
    if args.grace_minutes < 0:
        raise DeliverySyncError(f"--grace-minutes must not be negative, got {args.grace_minutes}")

    client = api or KubeApi(args.api_server, open_url=open_url)
    application = client.application(args.argocd_namespace, args.application)

    # The declared side first, so an unreadable applied side can be explained
    # rather than merely reported — the ordering #1318 arrived at independently.
    declared = resolve_declared(application, source_index=args.source_index, chart_name=args.chart_name)
    argo = read_argo_state(application)

    namespace = args.namespace or ((application.get("spec") or {}).get("destination") or {}).get("namespace")
    if not namespace:
        raise DeliverySyncError(
            "the Application declares no spec.destination.namespace, so there is no namespace to look in; "
            "pass --namespace."
        )

    controllers = read_controllers(client, namespace, args.application, args.chart_label)
    by_version = applied_versions(controllers, declared, args.chart_label)
    pods = client.list_items(f"/api/v1/namespaces/{namespace}/pods")

    findings = rollout_findings(controllers)
    image_problems, skipped = image_findings(controllers, pods)
    findings.extend(image_problems)

    verdict, all_findings = decide(declared, by_version, findings, argo, now=moment, grace_minutes=args.grace_minutes)
    report = build_report(
        declared,
        by_version,
        all_findings,
        skipped,
        verdict,
        argo,
        application=args.application,
        namespace=namespace,
        chart_label=args.chart_label,
        grace_minutes=args.grace_minutes,
        now=moment,
    )
    if args.json_path:
        with open(args.json_path, "w", encoding="utf-8") as handle:
            json.dump(report, handle, indent=2)

    if declared.prerelease:
        print(
            f"note: {declared.version} is a pre-release chart channel. Such a tag may be rewritten in "
            "place, which weakens the version-equals-content assumption this comparison relies on."
        )
    print(f"Application: {args.application} (namespace {namespace})")
    print(f"Declared:    chart {declared.chart_name} {declared.version} from source [{declared.source_index}]")
    for version in sorted(by_version):
        print(f"Applied:     {version} <- {', '.join(sorted(by_version[version]))}")
    print(f"ArgoCD says: sync={argo.sync_status} health={argo.health_status} operation={argo.operation_phase}")
    print(f"Verdict:     {verdict.name} — {verdict.headline}")
    for finding in all_findings:
        print(f"  finding [{finding.kind}] {finding.message}")
    for note in skipped:
        print(f"  not compared: {note}")
    return EXIT_DRIFT if verdict.is_alert else EXIT_OK


def run(argv: list[str] | None = None, **kwargs: Any) -> int:
    """Wrap :func:`main` in the fail-loud contract.

    Args:
        argv: Command line without the program name.
        **kwargs: Forwarded to :func:`main`.

    Returns:
        :data:`EXIT_UNDETERMINED` when the verdict could not be determined —
        loud, and with no report written, so a consumer acting on the report
        cannot mistake an undetermined check for a clean one.
    """
    try:
        return main(argv, **kwargs)
    except DeliverySyncError as exc:
        print(f"::error::delivery sync check could not be determined: {exc}", file=sys.stderr)
        return EXIT_UNDETERMINED
    except SystemExit as exc:  # argparse's own usage failure
        return EXIT_USAGE if exc.code not in (0, None) else EXIT_OK


if __name__ == "__main__":
    raise SystemExit(run())
