#!/usr/bin/env bash
set -Eeuo pipefail

readonly ROOT_DIR="$(cd "$(dirname "${0}")/.." && pwd)"
readonly NAMESPACE="${CYBER_DOJO_NAMESPACE:-cyber-dojo}"

show_help()
{
  # Prints the usage, with an example, to stdout.
  cat <<EOF
Usage: bin/test_traffic_light_saved.sh

Checks a cyber-dojo server that bin/up.sh installed, in the current kubectl
context and namespace ${NAMESPACE}, end to end. From inside the web pod it
creates a "Bash, bats" kata through nginx and runs its starter files through
web, as a browser does. It passes when that run is red and saver has stored
the red traffic-light in the kata. Needs kubectl.

Exercises: nginx, creator, languages-start-points, web, runner and its
Docker daemon, spooler, and saver's volume.

nginx admits one kata creation per minute from one address, and every run
comes from the web pod, so a second run within a minute fails with a 429.

Options:
  -h    Show this help

Example:
  bin/test_traffic_light_saved.sh
EOF
}

kata_log()
{
  # Prints the git log of kata $1 from saver's volume, one commit per line.
  local -r id="${1}"
  kubectl exec --namespace "${NAMESPACE}" saver-0 -- \
    git -C "/cyber-dojo/katas/${id:0:2}/${id:2:2}/${id:4:2}" log --oneline
}

main()
{
  # Runs the starter kata, then waits for saver to hold its red traffic-light.
  if [ "${1:-}" = '-h' ]; then
    show_help
    exit 0
  fi

  local id
  id="$(kubectl exec --namespace "${NAMESPACE}" --stdin deploy/web -- ruby \
    < "${ROOT_DIR}/test/run_starter_kata.rb")"
  echo "kata ${id}: run_tests answered red"

  # spooler forwards the traffic-light to saver after web has answered.
  for _ in $(seq 30); do
    if kata_log "${id}" | grep --quiet 'got red'; then
      echo "kata ${id}: saver holds the red traffic-light"
      echo PASSED
      exit 0
    fi
    sleep 1
  done
  echo "kata ${id}: saver holds no red traffic-light after 30s" >&2
  kata_log "${id}" >&2
  exit 42
}

main "$@"
