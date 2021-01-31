{{/*
Common labels shared across objects.
*/}}
{{- define "common.labels" -}}
argo.just-mfg.de/chart: {{ include "common.names.chart" . }}
{{ include "common.labels.selectorLabels" . }}
{{- if .Chart.AppVersion }}
argo.just-mfg.de/version: {{ .Chart.AppVersion | quote }}
{{- end }}
argo.just-mfg.de/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels shared across objects.
*/}}
{{- define "common.labels.selectorLabels" -}}
argo.just-mfg.de/name: {{ include "common.names.name" . }}
argo.just-mfg.de/instance: {{ .Release.Name }}
{{- end }}
