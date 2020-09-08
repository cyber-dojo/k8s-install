#!/bin/bash -Eeu

HELM_VERSION=$1

function install_helm()
{
    echo "Download and install helm"
    curl -Lo helm-$HELM_VERSION-linux-amd64.tar.gz https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz
    tar -zxvf helm-$HELM_VERSION-linux-amd64.tar.gz
    mv linux-amd64/helm /usr/local/bin/helm
    rm helm-$HELM_VERSION-linux-amd64.tar.gz
    rm -rf linux-amd64
    echo "Installing Tiller"
    kubectl -n kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller
    echo "Check status of tiller"
    kubectl -n kube-system  rollout status deploy/tiller-deploy
    echo "helm version"
    helm version
}

install_helm
