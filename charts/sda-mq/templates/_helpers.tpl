{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sda.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "sda.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sda.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "verifyPeer" -}}
  {{ if .Values.config.tls.verifyPeer }}
    {{-  print "verify_peer" -}}
  {{ else }}
    {{-  print "verify_none" -}}
  {{ end }}
{{- end -}}

{{- define "mqCert" -}}
    {{- if .Values.externalPkiService.tlsPath }}
        {{- printf "%s" (regexReplaceAll "^/*|/+" (printf "%s/%s" .Values.externalPkiService.tlsPath (required "a TLS certificate is required" .Values.config.tls.serverCert)) "/")}}
    {{- else }}
        {{- printf "/etc/rabbitmq/tls/%s" (required "a TLS certificate is required" .Values.config.tls.serverCert) }}
    {{- end -}}
{{- end -}}

{{- define "mqKey" -}}
    {{- if .Values.externalPkiService.tlsPath }}
        {{- printf "%s" (regexReplaceAll "^/*|/+" (printf "%s/%s" .Values.externalPkiService.tlsPath (required "a TLS key is required" .Values.config.tls.serverKey)) "/")}}
    {{- else }}
        {{- printf "/etc/rabbitmq/tls/%s" (required "a TLS key is required" .Values.config.tls.serverKey) }}
    {{- end -}}
{{- end -}}

{{- define "caCert" -}}
    {{- if .Values.externalPkiService.tlsPath }}
        {{- printf "%s" (regexReplaceAll "^/*|/+" (printf "%s/%s" .Values.externalPkiService.tlsPath (required "a CA certificate is required" .Values.config.tls.caCert)) "/")}}
    {{- else }}
        {{- printf "/etc/rabbitmq/tls/%s" (required "a CA certificate is required" .Values.config.tls.caCert) }}
    {{- end -}}
{{- end -}}