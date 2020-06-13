
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
