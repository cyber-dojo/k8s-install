#!/bin/bash -Eeuv
#
# as suggested in https://floatingsun.net/howto-cert-manager-with-ingress-nginx-on-gke/
#

# configure your EMAIL and STATIC_IP in ./env file

source ./env

#install cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --create-namespace \
  --namespace cert-manager \
  --version v0.15.2 \
  --set installCRDs=true

# install ClusterIssuer
# repeat until cert-manager is ready
max_retry=100
counter=1
set +e
until cat ./lets-encrypt-cluster-issuer.yaml | sed "s/{{EMAIL}}/$EMAIL/g" | kubectl apply -f -
do
   sleep 10
   [[ counter -eq $max_retry ]] && echo "Failed!" && exit 1
   echo "Trying again. Try #$counter"
   ((counter++))
done

set -e
helm install nginx-ingress stable/nginx-ingress \
  --create-namespace \
  --namespace nginx-ingress \
  --set rbac.create=true \
  --set "controller.service.loadBalancerIP=${STATIC_IP}"
