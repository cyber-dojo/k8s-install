#!/bin/bash
# Script to install k3s in machine executor

function install_k3s(){
    echo "know os"
    cat /etc/os-release
    echo "download and install k3s"
    curl -sfL https://get.k3s.io | sh -
    k3s --help
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo "start k3s cluster"
    kubectl get nodes -A

}

echo "install k3s"
install_k3s