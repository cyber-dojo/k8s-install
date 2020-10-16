#!/bin/bash
# Script to deploy cyberdojo in k3s

function deploy_cyberdojo() {
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    pwd
    ls -lrt
    cd ../packager
    ./package.sh
    echo "Package done, sleep for 10"
    sleep 10
    cd ./installer
    ./install.sh
}

echo "Deploy cyberdojo service in k3s cluster"
deploy_cyberdojo
sleep 50
# Verify installation
kubectl wait --for=condition=Ready pods --all -n cyber-dojo

