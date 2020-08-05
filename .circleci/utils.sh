#!/bin/bash
# Script to install k3s in machine executor
HELM_VERSION=$1

function install_k3s(){
    echo $PATH
    echo "download and install k3s"
    curl -sfL https://get.k3s.io | sh -
    k3s --help
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo "start k3s cluster"
    kubectl get nodes -A

}

function install_helm(){
    echo "download and install helm"
    curl -Lo helm-$HELM_VERSION-linux-amd64.tar.gz https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz && \
    tar -zxvf helm-$HELM_VERSION-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm helm-$HELM_VERSION-linux-amd64.tar.gz && \
    rm -rf linux-amd64
}

echo "install k3s"
install_k3s
echo "install helm"
install_helm