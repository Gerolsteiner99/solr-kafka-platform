{{/*
Expand the name of the chart.
*/}}
{{- define "zookeeper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "zookeeper.fullname" -}}
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
{{- define "zookeeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "zookeeper.labels" -}}
helm.sh/chart: {{ include "zookeeper.chart" . }}
{{ include "zookeeper.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "zookeeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "zookeeper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "zookeeper.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "zookeeper.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified headless service name.
*/}}
{{- define "zookeeper.headlessServiceName" -}}
{{- printf "%s-headless" (include "zookeeper.fullname" .) }}
{{- end }}

{{/*
Get the ZooKeeper servers string
*/}}
{{- define "zookeeper.servers" -}}
{{- $replicas := .Values.replicaCount | int }}
{{- $fullname := include "zookeeper.fullname" . }}
{{- $headlessService := include "zookeeper.headlessServiceName" . }}
{{- $servers := list }}
{{- range $i, $e := until $replicas }}
{{- $server := printf "server.%d=%s-%d.%s:2888:3888;2181" (add $i 1) $fullname $i $headlessService }}
{{- $servers = append $servers $server }}
{{- end }}
{{- join " " $servers }}
{{- end }}

{{/*
Get the ZooKeeper configuration
*/}}
{{- define "zookeeper.config" -}}
tickTime={{ .Values.configuration.tickTime }}
initLimit={{ .Values.configuration.initLimit }}
syncLimit={{ .Values.configuration.syncLimit }}
dataDir=/data
dataLogDir=/datalog
maxClientCnxns={{ .Values.configuration.maxClientCnxns }}
standaloneEnabled={{ .Values.configuration.standaloneEnabled }}
admin.enableServer={{ .Values.configuration.adminServerEnabled }}
clientPort=2181
quorumListenOnAllIPs=true
4lw.commands.whitelist={{ .Values.configuration.fourLetterWords }}
{{ include "zookeeper.servers" . }}
{{- end }}

{{/*
Get the ZooKeeper myid
*/}}
{{- define "zookeeper.myid" -}}
{{- printf "%d" (add .Values.global.ordinal 1) }}
{{- end }}
