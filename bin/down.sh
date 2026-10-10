#!/usr/bin/env bash
set -Eeuo pipefail

readonly NAMESPACE="${CYBER_DOJO_NAMESPACE:-cyber-dojo}"

show_help()
{
  # Prints the usage, with an example, to stdout.
  cat <<EOF
Usage: bin/down.sh

Uninstalls the cyber-dojo server that bin/up.sh installed in the current
kubectl context, in namespace ${NAMESPACE} (override with CYBER_DOJO_NAMESPACE).
Needs helm.

The saver and spooler PersistentVolumeClaims are kept, so a later
bin/up.sh finds the same katas and groups.

Options:
  -h    Show this help

Example:
  bin/down.sh
EOF
}

main()
{
  # Uninstalls the helm release, then says how to delete the kept volumes.
  if [ "${1:-}" = '-h' ]; then
    show_help
    exit 0
  fi
  helm uninstall cyber-dojo --namespace "${NAMESPACE}"
  echo "The saver and spooler volumes are kept. To delete them, and every kata:"
  echo "  kubectl delete pvc --namespace ${NAMESPACE} data-saver-0 data-spooler-0"
}

main "$@"
