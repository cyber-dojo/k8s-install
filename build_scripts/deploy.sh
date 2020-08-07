#!/bin/bash
# Script to deploy cyberdojo in k3s

function deploy_cyberdojo() {
    pwd
    ls -lrt
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

