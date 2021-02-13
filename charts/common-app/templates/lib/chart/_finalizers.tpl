{{/*
Return the appropriate apiVersion for application objects.
*/}}
{{- define "common.finalizers" -}}
{{- print "- resources-finalizer.argocd.argoproj.io" -}}
{{- end -}}
