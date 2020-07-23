#!/bin/bash
# Script to start k3d cluster and deploy cyberdojo

# Step1 - Start single node k3d cluster
# Step2 - Switch default context for kubeconfig
function setup_k3dcluster() {
    k3d cluster create cyberdojo
    k3d kubeconfig merge cyberdojo --switch-context
    kubectl get pods -A
}
# Change directory to packager and run necessary steps
function deploy_cyberdojo() {
    cd ../packager
    ./package.sh
    if [$? -gt 0]; then
        echo "Packaging errors identified"
        exit 1
    else
        echo "Package done"
        cd ./installer
        ./install.sh
        if [$? -gt 0]; then
            echo "installation failed"
            exit 1
        fi
    fi

}

echo "Inside deploy script"
echo "Spinning up k3d cluster"
setup_k3dcluster

echo "deploy cyberdojo service in k3d cluster"
deploy_cyberdojo

# Verify installation

