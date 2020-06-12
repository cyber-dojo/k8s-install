
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
    praqma/cyber-dojo-service \
    --version 0.2.5
}
