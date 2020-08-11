#!/bin/bash -Eeuv

readonly NAMESPACE=cyber-dojo
readonly REPO_VALUES_YML=k8s-general-values.yml

readonly INSTALLER_DIR=.
readonly INSTALLER_ENV=${INSTALLER_DIR}/env
readonly INSTALLER_USER_VALUES_DIR=${INSTALLER_DIR}
readonly INSTALLER_SH_DIR=${INSTALLER_DIR}/sh
readonly INSTALLER_DEFAULT_VALUES_DIR=${INSTALLER_DIR}/default-values

source ${INSTALLER_SH_DIR}/deployment_functions.sh
source ${INSTALLER_ENV}
echo "STARTTTTTTT"
# helm init --service-account tiller
echo "helmmm initttt doneeee"
helm repo add praqma https://praqma-helm-repo.s3.amazonaws.com/
echo "helm repoooo addeddddd"
helm repo update
echo "before namespace"
kubectl create namespace ${NAMESPACE} &> /dev/null && echo namespace "\"${NAMESPACE}\"" created || echo namespace "\"${NAMESPACE}\"" already exists
echo "passed this step and created ${NAMESPACE}"
kubectl get namespaces
# CUSTOM_START_POINTS
REPO=custom-start-points
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_CUSTOM_START_POINTS_IMAGE}" "${CYBER_DOJO_CUSTOM_START_POINTS_TAG}" "${CYBER_DOJO_CUSTOM_START_POINTS_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# LANGUAGES_START_POINTS
REPO=languages-start-points

helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_LANGUAGES_START_POINTS_IMAGE}" "${CYBER_DOJO_LANGUAGES_START_POINTS_TAG}" "${CYBER_DOJO_LANGUAGES_START_POINTS_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"
   
# EXERCISES_START_POINTS
REPO=exercises-start-points
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_EXERCISES_START_POINTS_IMAGE}" "${CYBER_DOJO_EXERCISES_START_POINTS_TAG}" "${CYBER_DOJO_EXERCISES_START_POINTS_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# CREATOR
REPO=creator
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_CREATOR_IMAGE}" "${CYBER_DOJO_CREATOR_TAG}" "${CYBER_DOJO_CREATOR_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# CUSTOM_CHOOSER
REPO=custom-chooser
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_CUSTOM_CHOOSER_IMAGE}" "${CYBER_DOJO_CUSTOM_CHOOSER_TAG}" "${CYBER_DOJO_CUSTOM_CHOOSER_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# EXERCISES_CHOOSER
REPO=exercises-chooser
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_EXERCISES_CHOOSER_IMAGE}" "${CYBER_DOJO_EXERCISES_CHOOSER_TAG}" "${CYBER_DOJO_EXERCISES_CHOOSER_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# LANGUAGES_CHOOSER
REPO=languages-chooser
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_LANGUAGES_CHOOSER_IMAGE}" "${CYBER_DOJO_LANGUAGES_CHOOSER_TAG}" "${CYBER_DOJO_LANGUAGES_CHOOSER_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# AVATARS
REPO=avatars
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_AVATARS_IMAGE}" "${CYBER_DOJO_AVATARS_TAG}" "${CYBER_DOJO_AVATARS_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# DIFFER
REPO=differ
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_DIFFER_IMAGE}" "${CYBER_DOJO_DIFFER_TAG}" "${CYBER_DOJO_DIFFER_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# RUNNER
REPO=runner
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_RUNNER_IMAGE}" "${CYBER_DOJO_RUNNER_TAG}" "${CYBER_DOJO_RUNNER_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# SAVER
REPO=saver
helm_upgrade_probe_no_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_SAVER_IMAGE}" "${CYBER_DOJO_SAVER_TAG}" "${CYBER_DOJO_SAVER_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}" "${INSTALLER_USER_VALUES_DIR}/saver-pvc.yml"

# REPLER
REPO=repler
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_REPLER_IMAGE}" "${CYBER_DOJO_REPLER_TAG}" "${CYBER_DOJO_REPLER_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# SHAS
REPO=shas
helm_upgrade_probe_yes_prometheus_yes "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_SHAS_IMAGE}" "${CYBER_DOJO_SHAS_TAG}" "${CYBER_DOJO_SHAS_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# WEB
REPO=web
helm_upgrade_probe_no_prometheus_no "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_WEB_IMAGE}" "${CYBER_DOJO_WEB_TAG}" "${CYBER_DOJO_WEB_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}"

# NGINX
REPO=nginx
helm_upgrade_probe_no_prometheus_no "${NAMESPACE}" "${REPO}" \
   "${CYBER_DOJO_NGINX_IMAGE}" "${CYBER_DOJO_NGINX_TAG}" "${CYBER_DOJO_NGINX_PORT}" \
   "${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}" "${INSTALLER_USER_VALUES_DIR}/nginx-ingress.yml"
