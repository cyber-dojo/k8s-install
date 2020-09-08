#!/bin/bash -Eeu

HELM_VERSION=$1

function install_k3s()
{
    echo "Download and install k3s"
    sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 664" sh -
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo "KUBECONFIG=$KUBECONFIG"
    sleep 25
}

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

install_k3s
install_helm
