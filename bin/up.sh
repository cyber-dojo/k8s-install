#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
readonly CHART_DIR="${ROOT_DIR}/chart/cyber-dojo"
readonly NAMESPACE="${CYBER_DOJO_NAMESPACE:-cyber-dojo}"
readonly VERSIONER_REPO=cyber-dojo/versioner
readonly RELEASE_PATTERN='[0-9]+\.[0-9]+\.[0-9]+'

show_help()
{
  # Prints the usage, with examples, to stdout.
  cat <<EOF
Usage: bin/up.sh [RELEASE] [HELM-ARGS...]

Installs, or upgrades to, one cyber-dojo release in the current kubectl
context, in namespace ${NAMESPACE} (override with CYBER_DOJO_NAMESPACE).
Needs curl and helm.

RELEASE is a ${VERSIONER_REPO} release number, eg 0.1.498.
Omitted, it is the newest release.
Any further arguments are passed to helm, eg --set or --values.

Options:
  -h    Show this help

Examples:
  bin/up.sh
  bin/up.sh 0.1.498
  bin/up.sh 0.1.498 --set ingress.host=cyber-dojo.example.com
EOF
}

search_release_commits()
{
  # Prints GitHub's commit-search JSON for versioner commits whose message
  # contains $1, newest first. A release commit's message starts [RELEASE=x.y.z].
  # A GITHUB_TOKEN, when set, lifts the low unauthenticated search rate limit,
  # which runners sharing one address (eg GitHub Actions) soon reach.
  local -r text="${1}"
  local -a auth=()
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    auth=(--header "Authorization: Bearer ${GITHUB_TOKEN}")
  fi
  curl --silent --show-error --fail "${auth[@]+"${auth[@]}"}" \
    "https://api.github.com/search/commits?q=repo:${VERSIONER_REPO}+%22${text}%22&sort=committer-date&order=desc&per_page=1"
}

first_match()
{
  # Prints the first match of extended regex $1 in stdin, or nothing.
  grep --only-matching --extended-regexp "${1}" | head -n 1 || true
}

release_commit()
{
  # Prints "SHA RELEASE" for versioner release $1, or for the newest release
  # when $1 is empty.
  local -r wanted="${1}"
  local json
  if [ -z "${wanted}" ]; then
    json="$(search_release_commits 'RELEASE=')"
  else
    json="$(search_release_commits "RELEASE=${wanted}")"
  fi
  local -r sha="$(echo "${json}" | first_match '"sha": *"[0-9a-f]{40}"' | first_match '[0-9a-f]{40}')"
  local -r release="$(echo "${json}" | first_match "\[RELEASE=${RELEASE_PATTERN}\]" | first_match "${RELEASE_PATTERN}")"
  if [ -z "${sha}" ] || [ -z "${release}" ]; then
    echo "ERROR: no ${VERSIONER_REPO} commit names [RELEASE=${wanted:-x.y.z}]" >&2
    exit 42
  fi
  # A search for 0.1.49 can also find 0.1.498.
  if [ -n "${wanted}" ] && [ "${release}" != "${wanted}" ]; then
    echo "ERROR: no ${VERSIONER_REPO} release ${wanted} (nearest found: ${release})" >&2
    exit 42
  fi
  echo "${sha} ${release}"
}

write_release_env()
{
  # Writes the app/.env of versioner commit $1 to file $2.
  local -r sha="${1}"
  local -r path="${2}"
  curl --silent --show-error --fail \
    "https://raw.githubusercontent.com/${VERSIONER_REPO}/${sha}/app/.env" > "${path}"
}

main()
{
  # Fetches one release's app/.env and runs helm with it as versionerEnv.
  if [ "${1:-}" = '-h' ]; then
    show_help
    exit 0
  fi

  local wanted=''
  if [[ "${1:-}" =~ ^${RELEASE_PATTERN}$ ]]; then
    wanted="${1}"
    shift
  fi

  # Assigned on its own line so set -e stops here when release_commit fails.
  local found sha release
  found="$(release_commit "${wanted}")"
  read -r sha release <<< "${found}"
  echo "Using versioner release ${release} (commit ${sha:0:7})"

  local env_file
  env_file="$(mktemp)"
  # Expanded now, because env_file is local and gone by the time EXIT fires.
  # shellcheck disable=SC2064
  trap "rm -f '${env_file}'" EXIT
  write_release_env "${sha}" "${env_file}"

  if ! grep --quiet '^CYBER_DOJO_RUNNER_IMAGE=' "${env_file}"; then
    echo "ERROR: versioner release ${release} has no CYBER_DOJO_RUNNER_IMAGE" >&2
    exit 42
  fi

  helm upgrade --install cyber-dojo "${CHART_DIR}" \
    --namespace "${NAMESPACE}" \
    --create-namespace \
    --description "versioner ${release}" \
    --set-file versionerEnv="${env_file}" \
    "$@"
}

main "$@"
