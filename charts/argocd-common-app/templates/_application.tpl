{{/*
This template serves as the blueprint for the Deployment objects that are created 
within the common library.
*/}}
{{- define "common.application" -}}
apiVersion: {{ include "common.capabilities.application.apiVersion" . }}
kind: Application
metadata:
  name: {{ include "common.names.fullname" . }}
  finalizers:
  {{- include "common.finalizers" . | nindent 4 }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
    {{- with .Values.controllerLabels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with .Values.controllerAnnotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  destination:
  {{- with .Values.destination }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
  project: {{ .Values.project }}
  source:
  {{- include "common.classes.source" . | nindent 4 }}
  syncPolicy:
  {{- with .Values.syncPolicy }}
  {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.ignoreDifferences }}
  ignoreDifferences:
  {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
