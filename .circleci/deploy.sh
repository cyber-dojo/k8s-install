#!/bin/bash
# Script to deploy cyberdojo in k3s

function deploy_cyberdojo() {
    pwd
    ls -lrt
    cd packager
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
echo "deploy cyberdojo service in k3s cluster"
deploy_cyberdojo

# Verify installation

