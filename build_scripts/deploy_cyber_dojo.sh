#!/bin/bash -Eeu

function deploy_cyber_dojo()
{
    echo "Deploy cyber-dojo service in k3s cluster"
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    pwd
    ls -lrt
    cd ../packager
    ./package.sh # creates installer/ dir
    echo "Package done, sleep for 10"
    sleep 10
    cd ./installer
    ./install.sh
}

deploy_cyber_dojo
sleep 50
# Verify installation
kubectl get deployments -n cyber-dojo
