
NAMESPACE="${1:-prod}"

function nodes()
{
   echo "Inside nodes"
  kubectl get nodes | tail -n +2 | cut -d' ' -f1
}

for node in $(nodes)
do
  kubectl describe node -n "${NAMESPACE}" "${node}"
done
