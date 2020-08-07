#!/bin/bash
# Script to install k3s in machine executor
HELM_VERSION=$1

function install_k3s(){
    echo $PATH
    echo "download and install k3s"
    sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 664" sh -
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo "KUBECONFIG = $KUBECONFIG"
    cat /etc/rancher/k3s/k3s.yaml
    sleep 25
    kubectl get nodes -A
    kubectl create namespace tester
    kbectl get namespaces

}

function install_helm(){
    echo "download and install helm"
    curl -Lo helm-$HELM_VERSION-linux-amd64.tar.gz https://get.helm.sh/helm-$HELM_VERSION-linux-amd64.tar.gz 
    tar -zxvf helm-$HELM_VERSION-linux-amd64.tar.gz 
    mv linux-amd64/helm /usr/local/bin/helm 
    rm helm-$HELM_VERSION-linux-amd64.tar.gz 
    rm -rf linux-amd64
    helm --help
}

echo "install k3s"
install_k3s
echo "install helm"
install_helm