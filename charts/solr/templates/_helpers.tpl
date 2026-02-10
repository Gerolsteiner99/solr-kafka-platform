{{/*
Expand the name of the chart.
*/}}
{{- define "solr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "solr.fullname" -}}
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
{{- define "solr.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "solr.labels" -}}
helm.sh/chart: {{ include "solr.chart" . }}
{{ include "solr.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "solr.selectorLabels" -}}
app.kubernetes.io/name: {{ include "solr.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "solr.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "solr.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified headless service name.
*/}}
{{- define "solr.headlessServiceName" -}}
{{- printf "%s-headless" (include "solr.fullname" .) }}
{{- end }}

{{/*
Get the Solr host
*/}}
{{- define "solr.host" -}}
{{- printf "$(POD_NAME).%s.%s.svc.cluster.local" (include "solr.headlessServiceName" .) .Release.Namespace }}
{{- end }}

{{/*
Get the ZooKeeper connection string
*/}}
{{- define "solr.zkHost" -}}
{{- .Values.zookeeper.connectionString }}
{{- end }}

{{/*
Get the Solr command arguments
*/}}
{{- define "solr.commandArgs" -}}
{{- $host := include "solr.host" . }}
{{- $zkHost := include "solr.zkHost" . }}
{{- printf "solr start -f -c -z \"%s\" -h \"%s\" -p 8983" $zkHost $host }}
{{- end }}
