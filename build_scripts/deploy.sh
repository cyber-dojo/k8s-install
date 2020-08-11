#!/bin/bash
# Script to deploy cyberdojo in k3s

function deploy_cyberdojo() {
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    pwd
    ls -lrt
    echo "helm init done early"
    helm init --service-account tiller
    cd ../packager
    ./package.sh
    echo "Package done"
    cd ./installer
    ./install.sh
}

echo "Inside deploy script"
echo "deploy cyberdojo service in k3s cluster"
deploy_cyberdojo

# Verify installation

