# Kamerplanter delivery check (hop 4)

Watches the last hop of the delivery chain, from inside the cluster.

```text
merge -> docker-publish (GHCR) -> Renovate digest PR (chart pin) -> ArgoCD sync
  ^                                        ^                            ^
  |                                        |                            |
  CI in nolte/kamerplanter        check_digest_freshness.py        THIS CHECK
                                                                   + #1318
```

Closes `nolte/kamerplanter#1236`.

## What it compares

| operand | where it comes from | what it proves |
| --- | --- | --- |
| **declared** | `Application.spec.sources[i].targetRevision` | which chart version this repository asks for |
| **applied** | `helm.sh/chart` on the owned Deployments / StatefulSets / DaemonSets | which chart version actually reached the API server |
| **running** | `observedGeneration`, replica counts, StatefulSet revisions, `Progressing` conditions, and each pod's `imageID` against the digest its spec pins | whether that chart actually reached every pod |

The first pair is the operand `nolte/kamerplanter#1318` structurally cannot see:
if ArgoCD never applies the *new* chart, the chart version #1318 measures is the
old one and everything is consistently old — clean, and wrong.

## What it can and cannot see

**It does not trust ArgoCD's self-report.** `status.sync.status == "Synced"` is
ArgoCD grading its own homework, and the 2026-08-17 incident is exactly the shape
where a green self-report and a stale deployment coexist. The self-report is
recorded in the JSON report as context and never decides the verdict — with two
exceptions, both of which only ever make the verdict *worse*: a sync operation in
`Failed`/`Error` and a Deployment whose `Progressing` condition reads
`ProgressDeadlineExceeded` bypass the grace window, because a component more
authoritative than this check has already concluded.

**Blind spots, stated:**

- It says nothing about whether the chart pins the *right* image. That is hop 3
  (`check_digest_freshness.py`) and #1318's comparison.
- It cannot see a change ArgoCD has not been told about. If this repository
  declares `0.2.2` and the live `Application` object still says `0.2.1`, the
  check compares 0.2.1 against 0.2.1 and reports `match`. That gap belongs to the
  `seed-job` Application, which is a different hop.
- The image-digest comparison only fires for digest-pinned containers. A
  tag-only reference is reported as *not compared*, never as clean.
- `helm.sh/chart` names a chart *version*, not chart *content*. Two publications
  of the same version are indistinguishable; a pre-release channel that is
  rewritten in place is flagged in the output.

## The three answers

The contract from #1318 is kept, because the same failure is available here: an
answer that cannot be read is not the same as an answer that says "wrong".

| answer | exit | verdict |
| --- | --- | --- |
| no `helm.sh/chart` on any owned workload | `1` | **not disclosed** — loud, no drift alert, no report written. Nothing is wrong with the deployment; the check cannot run against it. |
| a label whose version part is not a version | `1` | **undetermined** — loud, no verdict. |
| an exact chart version | `0` / `3` | the only answer that reaches the comparison |

The declared side has the mirror-image failure and is resolved **first**, so an
unreadable applied side can be explained rather than merely reported: a
`targetRevision` of `main`, `HEAD`, `*`, `1.2.x` or `>=1.2.0` is resolved by
ArgoCD at sync time and names no single chart version — undetermined, not drift.

Versions are compared as **exact strings**. There is no truncation rule, no
leading-`v` normalisation and no semver-range resolution anywhere, deliberately:
each of them is a thing to get wrong, and a comparison that quietly fixes up one
side is a comparison that can quietly agree with the wrong operand.

Reading a second label spelling is an explicit `--chart-label chart` opt-in and
never a silent fallback — two channels for one fact is its own drift class.

## The anchor

#1318 samples a health endpoint three times, because mid-rollout a Service
answers from a random replica. From inside the cluster that workaround is
unnecessary and replaced by something strictly better: **every pod is enumerated**,
so a split is observed deterministically rather than by chance. The property
worth keeping is kept — a split that survives the grace window escalates to
`drift` instead of being swallowed as `rolling`, so a *partial* hop-4 failure
cannot hide.

The grace window (default 60 min) is anchored on
`status.operationState.finishedAt`: the deployment cannot have been behind before
the apply that was supposed to fix it. With no sync operation recorded, the
weaker `status.reconciledAt` is used and the report says so. With neither, the
verdict is undetermined rather than assumed.

## Exit codes

| code | meaning |
| --- | --- |
| `0` | `match`, `within_grace` or `rolling` |
| `1` | undetermined — the check could not run. **Not** drift. |
| `2` | usage error |
| `3` | `drift` — the incident |

## How it alerts

`prometheusrule.yaml` turns those exit codes into alerts through
`kube_pod_container_status_last_terminated_exitcode`, which kube-state-metrics
v2.18 exports and this cluster's Prometheus already scrapes. Exit 3 is a
`critical` drift alert; exits 1 and 2 are a separate `warning` whose annotation
states that it is **not** drift. Two more rules watch the watcher: one for a
CronJob that stopped being scheduled, one for a CronJob that is missing or was
never scheduled at all.

**These alerts are visible, not delivered.** Measured 2026-09-01: Alertmanager
runs with every route ending in the `"null"` receiver, and
`argocd-notifications-controller` runs with a stock configuration carrying no
triggers, services or templates. Nothing on this cluster delivers a notification
anywhere. Wiring one Alertmanager receiver is the smallest thing that would close
that gap, and it is an operator decision rather than something this directory
should invent.

## Running it by hand

Read-only, from a workstation that can reach the API server:

```sh
kubectl proxy --port=8001 &
python3 check_delivery_sync.py \
  --application kamerplanter \
  --api-server http://127.0.0.1:8001 \
  --json /tmp/report.json
```

Inducing the other answer classes against the live cluster, still read-only:

```sh
# undetermined: source [0] tracks the moving revision `main`
python3 check_delivery_sync.py --application kamerplanter --source-index 0 \
  --api-server http://127.0.0.1:8001

# not disclosed: pihole's Deployment carries the legacy `chart` label
python3 check_delivery_sync.py --application pihole --api-server http://127.0.0.1:8001

# ... and the counter-proof that it is the label and not a broken read
python3 check_delivery_sync.py --application pihole --chart-label chart \
  --api-server http://127.0.0.1:8001
```

## Layout

| file | purpose |
| --- | --- |
| `check_delivery_sync.py` | the check; standard library only, no dependency to install |
| `test_check_delivery_sync.py` | `unittest` self-test, wired into `.pre-commit-config.yaml`; induces `drift`, which cannot be induced against a live cluster |
| `cronjob.yaml` | hourly CronJob, script mounted from a ConfigMap |
| `rbac.yaml` | read-only Roles: one Application in `argocd`, workloads in `kamerplanter` |
| `prometheusrule.yaml` | the four alert rules |
| `kustomization.yaml` | ties them together; carries **no** top-level `namespace:` on purpose |

## Traps recorded here so they are not rediscovered

- **`namespace:` in `kustomization.yaml` overwrites an explicit
  `metadata.namespace`.** With it set, the Role granting read access to the
  ArgoCD Application was rewritten from `argocd` into `kamerplanter`. Everything
  applies cleanly, the CronJob runs, and every run fails with HTTP 403 → exit 1
  forever: a watcher permanently red about its own configuration.
- **A CronWorkflow would have been the local precedent and the wrong choice.**
  kube-state-metrics exports Job and CronJob state and this Prometheus scrapes
  it; there is no ServiceMonitor for argo-workflows, so a failing CronWorkflow
  is scraped by nothing.
- **`metric =~ "1|2"` is not PromQL.** `=~` matches labels, not values; two exit
  codes need two `==` comparisons unioned with `or`.
- **`..._last_terminated_exitcode` outlives the problem.** `failedJobsHistoryLimit`
  keeps the failed pod, so without the 3h freshness bound in the alert
  expressions a single drift would fire forever.
