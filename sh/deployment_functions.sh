
HELM_CHART_REPO=praqma/cyber-dojo-service
HELM_CHART_VERSION=0.2.5

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
gcloud_init()
{
  # vars are in ci context

  echo ${GCP_K8S_CREDENTIALS} > /gcp/gcp-credentials.json

  gcloud auth activate-service-account \
    "${SERVICE_ACCOUNT}" \
    --key-file=/gcp/gcp-credentials.json

  gcloud container clusters get-credentials \
    "${CLUSTER}" \
    --zone "${ZONE}" \
    --project "${PROJECT}"
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
helm_init()
{
  helm init --client-only
  helm repo add praqma https://praqma-helm-repo.s3.amazonaws.com/
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
helm_upgrade()
{
  local -r namespace="${1}"
  local -r repo="${2}"
  local -r image="${3}"
  local -r tag="${4}"
  local -r port="${5}"
  local -r general_values="--values ${6}"

  set -x
  if [ -z "${7:-}" ]; then
    local -r specific_values=""
  else
    local -r specific_values="--values ${7}"
  fi

  if [ "${K8S_SET_PROMETHEUS:-x}" == "false" ]; then
    local -r k8s_prometheus=""
  else
    local dqt='"'
    local -r k8s_prometheus="--set-string service.annotations.${dqt}prometheus\.io/port${dqt}=${port}"
  fi

  if [ "${K8S_SET_PROBES:-x}" == "false" ]; then
    local -r k8s_liveness_probe=""
    local -r k8s_readiness_probe=""
  else
    local -r k8s_liveness_probe="--set containers[0].livenessProbe.port=${port}"
    local -r k8s_readiness_probe="--set containers[0].readinessProbe.port=${port}"
  fi

  helm upgrade \
    --install \
    --namespace=${namespace} \
    --set-string containers[0].image=${image} \
    --set-string containers[0].tag=${tag} \
    --set service.port=${port} \
    ${k8s_liveness_probe} \
    ${k8s_readiness_probe} \
    ${k8s_prometheus} \
    ${general_values} \
    ${specific_values} \
    ${namespace}-${repo} \
    ${HELM_CHART_REPO} \
    --version ${HELM_CHART_VERSION}
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
helm_upgrade_probe_no_prometheus_no()
{
  local -r namespace="${1}"
  local -r repo="${2}"
  local -r image="${3}"
  local -r tag="${4}"
  local -r port="${5}"
  local -r general_values="${6}"
  if [ -z "${7:-}" ]; then
    local -r specific_values=""
  else
    local -r specific_values="--values ${7}"
  fi

  helm upgrade \
    --install \
    --namespace=${namespace} \
    --set-string containers[0].image=${image} \
    --set-string containers[0].tag=${tag} \
    --set service.port=${port} \
    --values ${general_values} \
    ${specific_values} \
    ${namespace}-${repo} \
    ${HELM_CHART_REPO} \
    --version ${HELM_CHART_VERSION}
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
helm_upgrade_probe_yes_prometheus_no()
{
  local -r namespace="${1}"
  local -r repo="${2}"
  local -r image="${3}"
  local -r tag="${4}"
  local -r port="${5}"
  local -r general_values="${6}"
  local -r specific_values="${7}"

  helm upgrade \
    --install \
    --namespace=${namespace} \
    --set-string containers[0].image=${image} \
    --set-string containers[0].tag=${tag} \
    --set service.port=${port} \
    --set-string service.annotations."prometheus\.io/port"=${port} \
    --values ${general_values} \
    --values ${specific_values} \
    ${namespace}-${repo} \
    ${HELM_CHART_REPO} \
    --version ${HELM_CHART_VERSION}
}

#- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
helm_upgrade_probe_yes_prometheus_yes()
{
  local -r namespace="${1}"
  local -r repo="${2}"
  local -r image="${3}"
  local -r tag="${4}"
  local -r port="${5}"
  local -r general_values="${6}"
  if [ -z "${7:-}" ]; then
    local -r specific_values=""
  else
    local -r specific_values="--values ${7}"
  fi

  helm upgrade \
    --install \
    --namespace=${namespace} \
    --set-string containers[0].image=${image} \
    --set-string containers[0].tag=${tag} \
    --set service.port=${port} \
    --set containers[0].livenessProbe.port=${port} \
    --set containers[0].readinessProbe.port=${port} \
    --set-string service.annotations."prometheus\.io/port"=${port} \
    --values ${general_values} \
    ${specific_values} \
    ${namespace}-${repo} \
    ${HELM_CHART_REPO} \
    --version ${HELM_CHART_VERSION}
}
