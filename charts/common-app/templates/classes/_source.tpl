{{- define "common.classes.source" -}}
{{- $values := .Values.source -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.source -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}
{{- $default := dict "targetRevision" .Chart.AppVersion -}}
{{- $newdict := merge $values $default -}}
{{ toYaml $newdict }}
{{- end -}}