{{/* 
Merge the local chart values and the common chart defaults.
*/}}
{{- define "common.values.setup" -}}
  {{$common := get .Values "common-app" }}
  {{- if $common -}}
    {{- $defaultValues := deepCopy $common -}}
    {{- $userValues := deepCopy (omit .Values "common-app") -}}
    {{- $mergedValues := mustMergeOverwrite $defaultValues $userValues -}}
    {{- $_ := set . "Values" (deepCopy $mergedValues) -}}
  {{- end }}  
{{- end }}
