{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mongodb.name" -}}
{{- include "mongodb.names.name" . -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mongodb.fullname" -}}
{{- include "mongodb.names.fullname" . -}}
{{- end -}}

{{/*
Create a default mongo service name which can be overridden.
*/}}
{{- define "mongodb.service.nameOverride" -}}
    {{- if .Values.service -}}
        {{- if .Values.service.nameOverride }}
            {{- .Values.service.nameOverride -}}
        {{- else -}}
            {{ include "mongodb.fullname" . }}-headless
        {{- end -}}
    {{- else -}}
        {{ include "mongodb.fullname" . }}-headless
    {{- end }}
{{- end }}

{{/*
Create a default mongo arbiter service name which can be overridden.
*/}}
{{- define "mongodb.arbiter.service.nameOverride" -}}
    {{- if .Values.arbiter.service -}}
        {{- if .Values.arbiter.service.nameOverride }}
            {{- .Values.arbiter.service.nameOverride -}}
        {{- else -}}
            {{ include "mongodb.fullname" . }}-arbiter-headless
        {{- end -}}
    {{- else -}}
        {{ include "mongodb.fullname" . }}-arbiter-headless
    {{- end }}
{{- end }}

{{/*
Return the proper MongoDB(R) image name
*/}}
{{- define "mongodb.image" -}}
{{ include "mongodb.images.image" (dict "imageRoot" .Values.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the metrics image)
*/}}
{{- define "mongodb.metrics.image" -}}
{{ include "mongodb.images.image" (dict "imageRoot" .Values.metrics.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container volume-permissions image)
*/}}
{{- define "mongodb.volumePermissions.image" -}}
{{ include "mongodb.images.image" (dict "imageRoot" .Values.volumePermissions.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the init container auto-discovery image)
*/}}
{{- define "mongodb.externalAccess.autoDiscovery.image" -}}
{{ include "mongodb.images.image" (dict "imageRoot" .Values.externalAccess.autoDiscovery.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper image name (for the TLS Certs image)
*/}}
{{- define "mongodb.tls.image" -}}
{{ include "mongodb.images.image" (dict "imageRoot" .Values.tls.image "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "mongodb.imagePullSecrets" -}}
{{ include "mongodb.images.pullSecrets" (dict "images" (list .Values.image .Values.metrics.image .Values.volumePermissions.image) "global" .Values.global) }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names (deprecated: use mongodb.images.renderPullSecrets instead)
{{ include "mongodb.images.pullSecrets" ( dict "images" (list .Values.path.to.the.image1, .Values.path.to.the.image2) "global" .Values.global) }}
*/}}
{{- define "mongodb.images.pullSecrets" -}}
  {{- $pullSecrets := list }}

  {{- if .global }}
    {{- range .global.imagePullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- range .images -}}
    {{- range .pullSecrets -}}
      {{- $pullSecrets = append $pullSecrets . -}}
    {{- end -}}
  {{- end -}}

  {{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
    {{- range $pullSecrets }}
  - name: {{ . }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts.
*/}}
{{- define "mongodb.namespace" -}}
    {{- if .Values.global -}}
        {{- if .Values.global.namespaceOverride }}
            {{- .Values.global.namespaceOverride -}}
        {{- else -}}
            {{- .Release.Namespace -}}
        {{- end -}}
    {{- else -}}
        {{- .Release.Namespace -}}
    {{- end }}
{{- end -}}
{{- define "mongodb.serviceMonitor.namespace" -}}
    {{- if .Values.metrics.serviceMonitor.namespace -}}
        {{- .Values.metrics.serviceMonitor.namespace -}}
    {{- else -}}
        {{- include "mongodb.namespace" . -}}
    {{- end }}
{{- end -}}
{{- define "mongodb.prometheusRule.namespace" -}}
    {{- if .Values.metrics.prometheusRule.namespace -}}
        {{- .Values.metrics.prometheusRule.namespace -}}
    {{- else -}}
        {{- include "mongodb.namespace" . -}}
    {{- end }}
{{- end -}}

{{/*
Returns the proper service account name depending if an explicit service account name is set
in the values file. If the name is not set it will default to either mongodb.fullname if serviceAccount.create
is true or default otherwise.
*/}}
{{- define "mongodb.serviceAccountName" -}}
    {{- if .Values.serviceAccount.create -}}
        {{ default (include "mongodb.fullname" .) .Values.serviceAccount.name }}
    {{- else -}}
        {{ default "default" .Values.serviceAccount.name }}
    {{- end -}}
{{- end -}}

{{/*
Return the configmap with the MongoDB(R) configuration
*/}}
{{- define "mongodb.configmapName" -}}
{{- if .Values.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s" (include "mongodb.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created for MongoDB(R)
*/}}
{{- define "mongodb.createConfigmap" -}}
{{- if and .Values.configuration (not .Values.existingConfigmap) }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret with MongoDB(R) credentials
*/}}
{{- define "mongodb.secretName" -}}
    {{- if .Values.auth.existingSecret -}}
        {{- printf "%s" .Values.auth.existingSecret -}}
    {{- else -}}
        {{- printf "%s" (include "mongodb.fullname" .) -}}
    {{- end -}}
{{- end -}}

{{/*
Return true if a secret object should be created for MongoDB(R)
*/}}
{{- define "mongodb.createSecret" -}}
{{- if and .Values.auth.enabled (not .Values.auth.existingSecret) }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
Get the initialization scripts ConfigMap name.
*/}}
{{- define "mongodb.initdbScriptsCM" -}}
{{- if .Values.initdbScriptsConfigMap -}}
{{- printf "%s" .Values.initdbScriptsConfigMap -}}
{{- else -}}
{{- printf "%s-init-scripts" (include "mongodb.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if the Arbiter should be deployed
*/}}
{{- define "mongodb.arbiter.enabled" -}}
{{- if and (eq .Values.architecture "replicaset") .Values.arbiter.enabled }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
Return the configmap with the MongoDB(R) configuration for the Arbiter
*/}}
{{- define "mongodb.arbiter.configmapName" -}}
{{- if .Values.arbiter.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.arbiter.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-arbiter" (include "mongodb.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created for MongoDB(R) Arbiter
*/}}
{{- define "mongodb.arbiter.createConfigmap" -}}
{{- if and (eq .Values.architecture "replicaset") .Values.arbiter.enabled .Values.arbiter.configuration (not .Values.arbiter.existingConfigmap) }}
    {{- true -}}
{{- else -}}
{{- end -}}
{{- end -}}

{{/*
Return true if the Hidden should be deployed
*/}}
{{- define "mongodb.hidden.enabled" -}}
{{- if and (eq .Values.architecture "replicaset") .Values.hidden.enabled }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the configmap with the MongoDB(R) configuration for the Hidden
*/}}
{{- define "mongodb.hidden.configmapName" -}}
{{- if .Values.hidden.existingConfigmap -}}
    {{- printf "%s" (tpl .Values.hidden.existingConfigmap $) -}}
{{- else -}}
    {{- printf "%s-hidden" (include "mongodb.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a configmap object should be created for MongoDB(R) Hidden
*/}}
{{- define "mongodb.hidden.createConfigmap" -}}
{{- if and  (include "mongodb.hidden.enabled" .) .Values.hidden.enabled .Values.hidden.configuration (not .Values.hidden.existingConfigmap) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Compile all warnings into a single message, and call fail.
*/}}
{{- define "mongodb.validateValues" -}}
{{- $messages := list -}}
{{- $messages := append $messages (include "mongodb.validateValues.pspAndRBAC" .) -}}
{{- $messages := append $messages (include "mongodb.validateValues.architecture" .) -}}
{{- $messages := append $messages (include "mongodb.validateValues.customDatabase" .) -}}
{{- $messages := append $messages (include "mongodb.validateValues.externalAccessServiceType" .) -}}
{{- $messages := append $messages (include "mongodb.validateValues.loadBalancerIPsListLength" .) -}}
{{- $messages := append $messages (include "mongodb.validateValues.nodePortListLength" .) -}}
{{- $messages := append $messages (include "mongodb.validateValues.externalAccessAutoDiscoveryRBAC" .) -}}
{{- $messages := without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- if $message -}}
{{-   printf "\nVALUES VALIDATION:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/* Validate RBAC is created when using PSP */}}
{{- define "mongodb.validateValues.pspAndRBAC" -}}
{{- if and (.Values.podSecurityPolicy.create) (not .Values.rbac.create) -}}
mongodb: podSecurityPolicy.create, rbac.create
    Both podSecurityPolicy.create and rbac.create must be true, if you want
    to create podSecurityPolicy
{{- end -}}
{{- end -}}

{{/* Validate values of MongoDB(R) - must provide a valid architecture */}}
{{- define "mongodb.validateValues.architecture" -}}
{{- if and (ne .Values.architecture "standalone") (ne .Values.architecture "replicaset") -}}
mongodb: architecture
    Invalid architecture selected. Valid values are "standalone" and
    "replicaset". Please set a valid architecture (--set mongodb.architecture="xxxx")
{{- end -}}
{{- end -}}

{{/*
Validate values of MongoDB(R) - both auth.username and auth.database are necessary
to create a custom user and database during 1st initialization
*/}}
{{- define "mongodb.validateValues.customDatabase" -}}
{{- if or (and .Values.auth.username (not .Values.auth.database)) (and (not .Values.auth.username) .Values.auth.database) }}
mongodb: auth.username, auth.database
    Both auth.username and auth.database must be provided to create
    a custom user and database during 1st initialization.
    Please set both of them (--set auth.username="xxxx",auth.database="yyyy")
{{- end -}}
{{- end -}}


{{/*
Validate values of MongoDB(R) - service type for external access
*/}}
{{- define "mongodb.validateValues.externalAccessServiceType" -}}
{{- if and (eq .Values.architecture "replicaset") (not (eq .Values.externalAccess.service.type "NodePort")) (not (eq .Values.externalAccess.service.type "LoadBalancer")) (not (eq .Values.externalAccess.service.type "ClusterIP")) -}}
mongodb: externalAccess.service.type
    Available service type for external access are NodePort, LoadBalancer or ClusterIP.
{{- end -}}
{{- end -}}

{{/*
Validate values of MongoDB(R) - number of replicas must be the same than LoadBalancer IPs list
*/}}
{{- define "mongodb.validateValues.loadBalancerIPsListLength" -}}
{{- $replicaCount := int .Values.replicaCount }}
{{- $loadBalancerListLength := len .Values.externalAccess.service.loadBalancerIPs }}
{{- if and (eq .Values.architecture "replicaset") .Values.externalAccess.enabled (not .Values.externalAccess.autoDiscovery.enabled ) (eq .Values.externalAccess.service.type "LoadBalancer") (not (eq $replicaCount $loadBalancerListLength )) -}}
mongodb: .Values.externalAccess.service.loadBalancerIPs
    Number of replicas and loadBalancerIPs array length must be the same.
{{- end -}}
{{- end -}}

{{/*
Validate values of MongoDB(R) - number of replicas must be the same than NodePort list
*/}}
{{- define "mongodb.validateValues.nodePortListLength" -}}
{{- $replicaCount := int .Values.replicaCount }}
{{- $nodePortListLength := len .Values.externalAccess.service.nodePorts }}
{{- if and (eq .Values.architecture "replicaset") .Values.externalAccess.enabled (eq .Values.externalAccess.service.type "NodePort") (not (eq $replicaCount $nodePortListLength )) -}}
mongodb: .Values.externalAccess.service.nodePorts
    Number of replicas and nodePorts array length must be the same.
{{- end -}}
{{- end -}}

{{/*
Validate values of MongoDB(R) - RBAC should be enabled when autoDiscovery is enabled
*/}}
{{- define "mongodb.validateValues.externalAccessAutoDiscoveryRBAC" -}}
{{- if and (eq .Values.architecture "replicaset") .Values.externalAccess.enabled .Values.externalAccess.autoDiscovery.enabled (not .Values.rbac.create )}}
mongodb: rbac.create
    By specifying "externalAccess.enabled=true" and "externalAccess.autoDiscovery.enabled=true"
    an initContainer will be used to autodetect the external IPs/ports by querying the
    K8s API. Please note this initContainer requires specific RBAC resources. You can create them
    by specifying "--set rbac.create=true".
{{- end -}}
{{- end -}}

{{/*
Validate values of MongoDB(R) exporter URI string - auth.enabled and/or tls.enabled must be enabled or it defaults
*/}}
{{- define "mongodb.mongodb_exporter.uri" -}}
    {{- $uriTlsArgs := ternary "tls=true&tlsCertificateKeyFile=/certs/mongodb.pem&tlsCAFile=/certs/mongodb-ca-cert" "" .Values.tls.enabled -}}
    {{- $uriAuth := ternary "root:$(echo $MONGODB_ROOT_PASSWORD | sed -r \"s/@/%40/g;s/:/%3A/g\")@" "" .Values.auth.enabled -}}

    {{- printf "mongodb://%slocalhost:27017/admin?%s" $uriAuth $uriTlsArgs -}}
{{- end -}}


{{/*
Return the appropriate apiGroup for PodSecurityPolicy.
*/}}
{{- define "podSecurityPolicy.apiGroup" -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy" -}}
{{- else -}}
{{- print "extensions" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for PodSecurityPolicy.
*/}}
{{- define "podSecurityPolicy.apiVersion" -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "policy/v1beta1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return true if a TLS secret object should be created
*/}}
{{- define "mongodb.createTlsSecret" -}}
{{- if and .Values.tls.enabled (not .Values.tls.existingSecret) }}
    {{- true -}}
{{- end -}}
{{- end -}}

{{/*
Return the secret containing MongoDB(R) TLS certificates
*/}}
{{- define "mongodb.tlsSecretName" -}}
{{- $secretName := .Values.tls.existingSecret -}}
{{- if $secretName -}}
    {{- printf "%s" (tpl $secretName $) -}}
{{- else -}}
    {{- printf "%s-ca" (include "mongodb.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Usage:
{{ include "mongodb.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
*/}}

{{- define "mongodb.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Kubernetes standard labels
*/}}
{{- define "mongodb.labels.standard" -}}
app.kubernetes.io/name: {{ include "mongodb.names.name" . }}
helm.sh/chart: {{ include "mongodb.names.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "mongodb.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "mongodb.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Warning about using rolling tag.
Usage:
{{ include "mongodb.warnings.rollingTag" .Values.path.to.the.imageRoot }}
*/}}
{{- define "mongodb.warnings.rollingTag" -}}

{{- if and (contains "bitnami/" .repository) (not (.tag | toString | regexFind "-r\\d+$|sha256:")) }}
WARNING: Rolling tag detected ({{ .repository }}:{{ .tag }}), please note that it is strongly recommended to avoid using rolling tags in a production environment.
+info https://docs.bitnami.com/containers/how-to/understand-rolling-tags-containers/
{{- end }}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "mongodb.names.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mongodb.names.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mongodb.names.fullname" -}}
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
Return  the proper Storage Class
{{ include "mongodb.storage.class" ( dict "persistence" .Values.path.to.the.persistence "global" $) }}
*/}}
{{- define "mongodb.storage.class" -}}

{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}

{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return a soft nodeAffinity definition
{{ include "mongodb.affinities.nodes.soft" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "mongodb.affinities.nodes.soft" -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - preference:
      matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
    weight: 1
{{- end -}}

{{/*
Return a hard nodeAffinity definition
{{ include "mongodb.affinities.nodes.hard" (dict "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "mongodb.affinities.nodes.hard" -}}
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: {{ .key }}
          operator: In
          values:
            {{- range .values }}
            - {{ . | quote }}
            {{- end }}
{{- end -}}

{{/*
Return a nodeAffinity definition
{{ include "mongodb.affinities.nodes" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "mongodb.affinities.nodes" -}}
  {{- if eq .type "soft" }}
    {{- include "mongodb.affinities.nodes.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "mongodb.affinities.nodes.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return a soft podAffinity/podAntiAffinity definition
{{ include "mongodb.affinities.pods.soft" (dict "component" "FOO" "extraMatchLabels" .Values.extraMatchLabels "context" $) -}}
*/}}
{{- define "mongodb.affinities.pods.soft" -}}
{{- $component := default "" .component -}}
{{- $extraMatchLabels := default (dict) .extraMatchLabels -}}
preferredDuringSchedulingIgnoredDuringExecution:
  - podAffinityTerm:
      labelSelector:
        matchLabels: {{- (include "mongodb.labels.matchLabels" .context) | nindent 10 }}
          {{- if not (empty $component) }}
          {{ printf "app.kubernetes.io/component: %s" $component }}
          {{- end }}
          {{- range $key, $value := $extraMatchLabels }}
          {{ $key }}: {{ $value | quote }}
          {{- end }}
      namespaces:
        - {{ .context.Release.Namespace | quote }}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end -}}

{{/*
Return a hard podAffinity/podAntiAffinity definition
{{ include "mongodb.affinities.pods.hard" (dict "component" "FOO" "extraMatchLabels" .Values.extraMatchLabels "context" $) -}}
*/}}
{{- define "mongodb.affinities.pods.hard" -}}
{{- $component := default "" .component -}}
{{- $extraMatchLabels := default (dict) .extraMatchLabels -}}
requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels: {{- (include "mongodb.labels.matchLabels" .context) | nindent 8 }}
        {{- if not (empty $component) }}
        {{ printf "app.kubernetes.io/component: %s" $component }}
        {{- end }}
        {{- range $key, $value := $extraMatchLabels }}
        {{ $key }}: {{ $value | quote }}
        {{- end }}
    namespaces:
      - {{ .context.Release.Namespace | quote }}
    topologyKey: kubernetes.io/hostname
{{- end -}}

{{/*
Return a podAffinity/podAntiAffinity definition
{{ include "mongodb.affinities.pods" (dict "type" "soft" "key" "FOO" "values" (list "BAR" "BAZ")) -}}
*/}}
{{- define "mongodb.affinities.pods" -}}
  {{- if eq .type "soft" }}
    {{- include "mongodb.affinities.pods.soft" . -}}
  {{- else if eq .type "hard" }}
    {{- include "mongodb.affinities.pods.hard" . -}}
  {{- end -}}
{{- end -}}

{{/*
Return the target Kubernetes version
*/}}
{{- define "mongodb.capabilities.kubeVersion" -}}
{{- if .Values.global }}
    {{- if .Values.global.kubeVersion }}
    {{- .Values.global.kubeVersion -}}
    {{- else }}
    {{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
    {{- end -}}
{{- else }}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for deployment.
*/}}
{{- define "mongodb.capabilities.deployment.apiVersion" -}}
{{- if semverCompare "<1.14-0" (include "mongodb.capabilities.kubeVersion" .) -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for RBAC resources.
*/}}
{{- define "mongodb.capabilities.rbac.apiVersion" -}}
{{- if semverCompare "<1.17-0" (include "mongodb.capabilities.kubeVersion" .) -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for statefulset.
*/}}
{{- define "mongodb.capabilities.statefulset.apiVersion" -}}
{{- if semverCompare "<1.14-0" (include "mongodb.capabilities.kubeVersion" .) -}}
{{- print "apps/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper image name
{{ include "mongodb.images.image" ( dict "imageRoot" .Values.path.to.the.image "global" $) }}
*/}}
{{- define "mongodb.images.image" -}}
{{- $registryName := .imageRoot.registry -}}
{{- $repositoryName := .imageRoot.repository -}}
{{- $tag := .imageRoot.tag | toString -}}
{{- if .global }}
    {{- if .global.imageRegistry }}
     {{- $registryName = .global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Validate MongoDB(R) required passwords are not empty.

Usage:
{{ include "mongodb.validations.values.mongodb.passwords" (dict "secret" "secretName" "subchart" false "context" $) }}
Params:
  - secret - String - Required. Name of the secret where MongoDB(R) values are stored, e.g: "mongodb-passwords-secret"
  - subchart - Boolean - Optional. Whether MongoDB(R) is used as subchart or not. Default: false
*/}}
{{- define "mongodb.validations.values.mongodb.passwords" -}}
  {{- $existingSecret := include "mongodb.values.auth.existingSecret" . -}}
  {{- $enabled := include "mongodb.values.enabled" . -}}
  {{- $authPrefix := include "mongodb.values.key.auth" . -}}
  {{- $architecture := include "mongodb.values.architecture" . -}}
  {{- $valueKeyRootPassword := printf "%s.rootPassword" $authPrefix -}}
  {{- $valueKeyUsername := printf "%s.username" $authPrefix -}}
  {{- $valueKeyDatabase := printf "%s.database" $authPrefix -}}
  {{- $valueKeyPassword := printf "%s.password" $authPrefix -}}
  {{- $valueKeyReplicaSetKey := printf "%s.replicaSetKey" $authPrefix -}}
  {{- $valueKeyAuthEnabled := printf "%s.enabled" $authPrefix -}}

  {{- $authEnabled := include "mongodb.utils.getValueFromKey" (dict "key" $valueKeyAuthEnabled "context" .context) -}}

  {{- if and (not $existingSecret) (eq $enabled "true") (eq $authEnabled "true") -}}
    {{- $requiredPasswords := list -}}

    {{- $requiredRootPassword := dict "valueKey" $valueKeyRootPassword "secret" .secret "field" "mongodb-root-password" -}}
    {{- $requiredPasswords = append $requiredPasswords $requiredRootPassword -}}

    {{- $valueUsername := include "mongodb.utils.getValueFromKey" (dict "key" $valueKeyUsername "context" .context) }}
    {{- $valueDatabase := include "mongodb.utils.getValueFromKey" (dict "key" $valueKeyDatabase "context" .context) }}
    {{- if and $valueUsername $valueDatabase -}}
        {{- $requiredPassword := dict "valueKey" $valueKeyPassword "secret" .secret "field" "mongodb-password" -}}
        {{- $requiredPasswords = append $requiredPasswords $requiredPassword -}}
    {{- end -}}

    {{- if (eq $architecture "replicaset") -}}
        {{- $requiredReplicaSetKey := dict "valueKey" $valueKeyReplicaSetKey "secret" .secret "field" "mongodb-replica-set-key" -}}
        {{- $requiredPasswords = append $requiredPasswords $requiredReplicaSetKey -}}
    {{- end -}}

    {{- include "mongodb.validations.values.multiple.empty" (dict "required" $requiredPasswords "context" .context) -}}

  {{- end -}}
{{- end -}}

{{/*
Auxiliary function to get the right value for existingSecret.

Usage:
{{ include "mongodb.values.auth.existingSecret" (dict "context" $) }}
Params:
  - subchart - Boolean - Optional. Whether MongoDb is used as subchart or not. Default: false
*/}}
{{- define "mongodb.values.auth.existingSecret" -}}
  {{- if .subchart -}}
    {{- .context.Values.mongodb.auth.existingSecret | quote -}}
  {{- else -}}
    {{- .context.Values.auth.existingSecret | quote -}}
  {{- end -}}
{{- end -}}

{{/*
Auxiliary function to get the right value for enabled mongodb.

Usage:
{{ include "mongodb.mongodb.values.enabled" (dict "context" $) }}
*/}}
{{- define "mongodb.values.enabled" -}}
  {{- if .subchart -}}
    {{- printf "%v" .context.Values.mongodb.enabled -}}
  {{- else -}}
    {{- printf "%v" (not .context.Values.enabled) -}}
  {{- end -}}
{{- end -}}

{{/*
Auxiliary function to get the right value for the key auth

Usage:
{{ include "mongodb.values.key.auth" (dict "subchart" "true" "context" $) }}
Params:
  - subchart - Boolean - Optional. Whether MongoDB(R) is used as subchart or not. Default: false
*/}}
{{- define "mongodb.values.key.auth" -}}
  {{- if .subchart -}}
    mongodb.auth
  {{- else -}}
    auth
  {{- end -}}
{{- end -}}

{{/*
Auxiliary function to get the right value for architecture

Usage:
{{ include "mongodb.mongodb.values.architecture" (dict "subchart" "true" "context" $) }}
Params:
  - subchart - Boolean - Optional. Whether MariaDB is used as subchart or not. Default: false
*/}}
{{- define "mongodb.values.architecture" -}}
  {{- if .subchart -}}
    {{- .context.Values.mongodb.architecture -}}
  {{- else -}}
    {{- .context.Values.architecture -}}
  {{- end -}}
{{- end -}}

{{/*
Gets a value from .Values given
Usage:
{{ include "mongodb.utils.getValueFromKey" (dict "key" "path.to.key" "context" $) }}
*/}}
{{- define "mongodb.utils.getValueFromKey" -}}
{{- $splitKey := splitList "." .key -}}
{{- $value := "" -}}
{{- $latestObj := $.context.Values -}}
{{- range $splitKey -}}
  {{- if not $latestObj -}}
    {{- printf "please review the entire path of '%s' exists in values" $.key | fail -}}
  {{- end -}}
  {{- $value = ( index $latestObj . ) -}}
  {{- $latestObj = $value -}}
{{- end -}}
{{- printf "%v" (default "" $value) -}}
{{- end -}}

{{/*
Through error when upgrading using empty passwords values that must not be empty.

Usage:
{{- $validationError00 := include "mongodb.validations.values.single.empty" (dict "valueKey" "path.to.password00" "secret" "secretName" "field" "password-00") -}}
{{- $validationError01 := include "mongodb.validations.values.single.empty" (dict "valueKey" "path.to.password01" "secret" "secretName" "field" "password-01") -}}
{{ include "mongodb.errors.upgrade.passwords.empty" (dict "validationErrors" (list $validationError00 $validationError01) "context" $) }}

Required password params:
  - validationErrors - String - Required. List of validation strings to be return, if it is empty it won't throw error.
  - context - Context - Required. Parent context.
*/}}
{{- define "mongodb.errors.upgrade.passwords.empty" -}}
  {{- $validationErrors := join "" .validationErrors -}}
  {{- if and $validationErrors .context.Release.IsUpgrade -}}
    {{- $errorString := "\nPASSWORDS ERROR: You must provide your current passwords when upgrading the release." -}}
    {{- $errorString = print $errorString "\n                 Note that even after reinstallation, old credentials may be needed as they may be kept in persistent volume claims." -}}
    {{- $errorString = print $errorString "\n                 Further information can be obtained at https://docs.bitnami.com/general/how-to/troubleshoot-helm-chart-issues/#credential-errors-while-upgrading-chart-releases" -}}
    {{- $errorString = print $errorString "\n%s" -}}
    {{- printf $errorString $validationErrors | fail -}}
  {{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Validate values must not be empty.

Usage:
{{- $validateValueConf00 := (dict "valueKey" "path.to.value" "secret" "secretName" "field" "password-00") -}}
{{- $validateValueConf01 := (dict "valueKey" "path.to.value" "secret" "secretName" "field" "password-01") -}}
{{ include "common.validations.values.empty" (dict "required" (list $validateValueConf00 $validateValueConf01) "context" $) }}

Validate value params:
  - valueKey - String - Required. The path to the validating value in the values.yaml, e.g: "mysql.password"
  - secret - String - Optional. Name of the secret where the validating value is generated/stored, e.g: "mysql-passwords-secret"
  - field - String - Optional. Name of the field in the secret data, e.g: "mysql-password"
*/}}
{{- define "mongodb.validations.values.multiple.empty" -}}
  {{- range .required -}}
    {{- include "mongodb.validations.values.single.empty" (dict "valueKey" .valueKey "secret" .secret "field" .field "context" $.context) -}}
  {{- end -}}
{{- end -}}

{{/*
Validate a value must not be empty.

Usage:
{{ include "common.validations.value.empty" (dict "valueKey" "mariadb.password" "secret" "secretName" "field" "my-password" "subchart" "subchart" "context" $) }}

Validate value params:
  - valueKey - String - Required. The path to the validating value in the values.yaml, e.g: "mysql.password"
  - secret - String - Optional. Name of the secret where the validating value is generated/stored, e.g: "mysql-passwords-secret"
  - field - String - Optional. Name of the field in the secret data, e.g: "mysql-password"
  - subchart - String - Optional - Name of the subchart that the validated password is part of.
*/}}
{{- define "mongodb.validations.values.single.empty" -}}
  {{- $value := include "mongodb.utils.getValueFromKey" (dict "key" .valueKey "context" .context) }}
  {{- $subchart := ternary "" (printf "%s." .subchart) (empty .subchart) }}

  {{- if not $value -}}
    {{- $varname := "my-value" -}}
    {{- $getCurrentValue := "" -}}
    {{- if and .secret .field -}}
      {{- $varname = include "mongodb.utils.fieldToEnvVar" . -}}
      {{- $getCurrentValue = printf " To get the current value:\n\n        %s\n" (include "mongodb.utils.secret.getvalue" .) -}}
    {{- end -}}
    {{- printf "\n    '%s' must not be empty, please add '--set %s%s=$%s' to the command.%s" .valueKey $subchart .valueKey $varname $getCurrentValue -}}
  {{- end -}}
{{- end -}}

{{/*
Print instructions to get a secret value.
Usage:
{{ include "common.utils.secret.getvalue" (dict "secret" "secret-name" "field" "secret-value-field" "context" $) }}
*/}}
{{- define "mongodb.utils.secret.getvalue" -}}
{{- $varname := include "mongodb.utils.fieldToEnvVar" . -}}
export {{ $varname }}=$(kubectl get secret --namespace {{ .context.Release.Namespace | quote }} {{ .secret }} -o jsonpath="{.data.{{ .field }}}" | base64 --decode)
{{- end -}}

{{/*
Build env var name given a field
Usage:
{{ include "mongodb.utils.fieldToEnvVar" dict "field" "my-password" }}
*/}}
{{- define "mongodb.utils.fieldToEnvVar" -}}
  {{- $fieldNameSplit := splitList "-" .field -}}
  {{- $upperCaseFieldNameSplit := list -}}

  {{- range $fieldNameSplit -}}
    {{- $upperCaseFieldNameSplit = append $upperCaseFieldNameSplit ( upper . ) -}}
  {{- end -}}

  {{ join "_" $upperCaseFieldNameSplit }}
{{- end -}}
