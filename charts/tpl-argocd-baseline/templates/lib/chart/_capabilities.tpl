{{/*
Return the appropriate apiVersion for application objects.
*/}}
{{- define "common.capabilities.application.apiVersion" -}}
{{- print "argoproj.io/v1alpha1" -}}
{{- end -}}
