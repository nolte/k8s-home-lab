{{/*
Expand the name of the chart.
*/}}
{{- define "argo-workflows-execution.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "argo-workflows-execution.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "argo-workflows-execution.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "argo-workflows-execution.labels" -}}
helm.sh/chart: {{ include "argo-workflows-execution.chart" . }}
{{ include "argo-workflows-execution.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "argo-workflows-execution.selectorLabels" -}}
app.kubernetes.io/name: {{ include "argo-workflows-execution.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "argo-workflows-execution.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "argo-workflows-execution.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "argo-workflows-execution.roleBindingKind" -}}
{{- if eq .Values.roleBinding.type "ClusterRole" -}}
ClusterRoleBinding
{{- else -}}
RoleBinding
{{- end -}}
{{- end -}}


{{- define "argo-workflows-execution.roleKind" -}}
{{- if eq .Values.role.type "ClusterRole" -}}
ClusterRole
{{- else -}}
Role
{{- end -}}
{{- end -}}


{{/*
Create the name of the Role to use
*/}}
{{- define "argo-workflows-execution.roleVaultInjectorName" -}}
{{- printf "%s-%s" (default (include "argo-workflows-execution.fullname" .) .Values.role.vaultInjector.name) "vault" | trunc 63 | trimSuffix "-" }}
{{- end }}



{{- define "argo-workflows-execution.roleK8SStateName" -}}
{{- printf "%s-%s" (default (include "argo-workflows-execution.fullname" .) .Values.role.vaultInjector.name) "state" | trunc 63 | trimSuffix "-" }}
{{- end }}