#!/bin/bash -Eeuv

readonly CYBER_DOJO_VERSION=${1:-master}

# initialize
readonly INSTALLER_DIR=installer
readonly INSTALLER_ENV=${INSTALLER_DIR}/env
readonly INSTALLER_USER_VALUES_DIR=${INSTALLER_DIR}
readonly INSTALLER_SH_DIR=${INSTALLER_DIR}/sh
readonly INSTALLER_DEFAULT_VALUES_DIR=${INSTALLER_DIR}/default-values

echo "Inside Package.sh"
mkdir  -p ${INSTALLER_DIR}
rm -rf ${INSTALLER_DIR}/*
mkdir  -p ${INSTALLER_SH_DIR}
mkdir  -p ${INSTALLER_DEFAULT_VALUES_DIR}
mkdir  -p ${INSTALLER_USER_VALUES_DIR}

readonly GITHUB_RAW_CONTENT=https://raw.githubusercontent.com
readonly GITHUB_ORGANIZATION=cyber-dojo
readonly REPO_VALUES_YML=k8s-general-values.yml
readonly ENV_VAR_VALUES_YML=env-var-values.yml

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/versioner/${CYBER_DOJO_VERSION}/app/.env > ${INSTALLER_ENV}
source ${INSTALLER_ENV}

readonly CYBER_DOJO_K8S_INSTALL_VERSION=${CYBER_DOJO_K8S_INSTALL_SHA}
curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/k8s-install/${CYBER_DOJO_K8S_INSTALL_VERSION}/sh/deployment_functions.sh > ${INSTALLER_SH_DIR}/deployment_functions.sh
cp install.sh.resource ${INSTALLER_DIR}/install.sh
chmod a+x ${INSTALLER_DIR}/install.sh


# CUSTOM_START_POINTS
REPO=custom-start-points
SHA="${CYBER_DOJO_CUSTOM_START_POINTS_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# LANGUAGES_START_POINTS
REPO=languages-start-points
SHA="${CYBER_DOJO_LANGUAGES_START_POINTS_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# EXERCISES_START_POINTS
REPO=exercises-start-points
SHA="${CYBER_DOJO_EXERCISES_START_POINTS_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# CREATOR
REPO=creator
SHA="${CYBER_DOJO_CREATOR_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# DASHBOARD
REPO=dashboard
SHA="${CYBER_DOJO_DASHBOARD_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# DIFFER
REPO=differ
SHA="${CYBER_DOJO_DIFFER_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# RUNNER
REPO=runner
SHA="${CYBER_DOJO_RUNNER_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# SAVER
REPO=saver
SHA="${CYBER_DOJO_SAVER_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}
# Don't append env-var-values.yml for saver (it's CI pipe is currently broken)

cat saver-security.yml.resource >> ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}
cp saver-pvc.yml.resource ${INSTALLER_USER_VALUES_DIR}/saver-pvc.yml

# REPLER
REPO=repler
SHA="${CYBER_DOJO_REPLER_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# SHAS

REPO=shas
SHA="${CYBER_DOJO_SHAS_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# WEB
REPO=web
SHA="${CYBER_DOJO_WEB_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
 > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

# NGINX
REPO=nginx
SHA="${CYBER_DOJO_NGINX_SHA}"

curl ${GITHUB_RAW_CONTENT}/${GITHUB_ORGANIZATION}/${REPO}/${SHA}/.circleci/${REPO_VALUES_YML} \
  > ${INSTALLER_DEFAULT_VALUES_DIR}/${REPO}-${REPO_VALUES_YML}

cp nginx-ingress.yml.resource ${INSTALLER_USER_VALUES_DIR}/nginx-ingress.yml
