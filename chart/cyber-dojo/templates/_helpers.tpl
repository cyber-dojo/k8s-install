{{/*
The versioner release's app/.env, passed in as .Values.versionerEnv by
bin/up.sh, as a YAML map of KEY: value, read back with fromYaml.
Blank lines and lines without an = are skipped.
*/}}
{{- define "cyber-dojo.versioner" -}}
{{- $text := required "versionerEnv is empty; install with bin/up.sh, which sets it from a versioner release" .Values.versionerEnv -}}
{{- $env := dict -}}
{{- range $line := splitList "\n" $text -}}
{{- $kv := splitn "=" 2 (trim $line) -}}
{{- if and $kv._0 $kv._1 -}}
{{- $_ := set $env $kv._0 $kv._1 -}}
{{- end -}}
{{- end -}}
{{- toYaml $env -}}
{{- end -}}

{{/*
The image reference for one service, pinned to its versionerEnv digest unless
the service's values set image: explicitly.
Call with (dict "root" $ "envPrefix" "SAVER" "image" .image).
*/}}
{{- define "cyber-dojo.image" -}}
{{- if .image -}}
{{- .image -}}
{{- else -}}
{{- $v := fromYaml (include "cyber-dojo.versioner" .root) -}}
{{- $name := get $v (printf "CYBER_DOJO_%s_IMAGE" .envPrefix) -}}
{{- $tag := get $v (printf "CYBER_DOJO_%s_TAG" .envPrefix) -}}
{{- $digest := get $v (printf "CYBER_DOJO_%s_DIGEST" .envPrefix) -}}
{{- required (printf "versionerEnv has no CYBER_DOJO_%s_IMAGE" .envPrefix) $name -}}:{{ $tag }}@sha256:{{ $digest }}
{{- end -}}
{{- end -}}

{{/*
The port one service listens on, from versionerEnv.
Call with (dict "root" $ "envPrefix" "SAVER").
*/}}
{{- define "cyber-dojo.port" -}}
{{- $v := fromYaml (include "cyber-dojo.versioner" .root) -}}
{{- required (printf "versionerEnv has no CYBER_DOJO_%s_PORT" .envPrefix) (get $v (printf "CYBER_DOJO_%s_PORT" .envPrefix)) -}}
{{- end -}}

{{/*
A peer's hostname, fully qualified because nginx's resolver ignores
resolv.conf search domains.
*/}}
{{- define "cyber-dojo.fqdn" -}}
{{- .name }}.{{ .root.Release.Namespace }}.svc.{{ .root.Values.clusterDomain -}}
{{- end -}}

{{/*
Labels selecting one service's pods.
*/}}
{{- define "cyber-dojo.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end -}}

{{/*
Labels on every object the chart creates for one service.
*/}}
{{- define "cyber-dojo.labels" -}}
{{ include "cyber-dojo.selectorLabels" . }}
app.kubernetes.io/part-of: cyber-dojo
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
helm.sh/chart: {{ .root.Chart.Name }}-{{ .root.Chart.Version }}
{{- end -}}
