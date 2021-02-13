{{/* 
Merge the local chart values and the common chart defaults.
*/}}
{{- define "argoapp.destination" -}}
destination:
  namespace: {{.namespace}}
  name: {{.name}}
{{- end }}
{{- define "argoapp.syncPolicy" -}}
 syncPolicy:
   automated: {}
   syncOptions:
     - CreateNamespace=true  
{{- end }}