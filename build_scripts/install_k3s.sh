#!/bin/bash -Eeu

function install_k3s()
{
    echo "Download and install k3s"
    sudo curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig-mode 664" sh -
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    echo "KUBECONFIG=$KUBECONFIG"
    sleep 25
}

install_k3s
