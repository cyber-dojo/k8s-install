#!/bin/bash -Eeu
#
# as suggested in https://floatingsun.net/howto-cert-manager-with-ingress-nginx-on-gke/
#

# configure your values in ./env file

source ./env

kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --create-namespace \
  --namespace cert-manager \
  --version v0.12.0 \
  --set webhook.enabled=false

cat ./lets-encrypt-cluster-issuer.yaml | sed "s/{{EMAIL}}/$EMAIL/g" | kubectl apply -f -

helm install nginx-ingress stable/nginx-ingress \
  --create-namespace \
  --namespace nginx-ingress \
  --set rbac.create=true \
  --set "controller.service.loadBalancerIP=${STATIC_IP}"
