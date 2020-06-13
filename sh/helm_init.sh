
helm_init()
{
  helm init --client-only
  helm repo add praqma https://praqma-helm-repo.s3.amazonaws.com/
}
