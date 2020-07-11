# k8s-install

Cyber-Dojo can be installed on any kubernetes cluster. This project contains installation scripts and instructions.

## Prerequisites

- bash
- Kubernetes 1.15+
- or Minikube 1.11+ with virtual-box driver and enabled ingress addon
- Helm V3 installed

## Getting started

### (optional) Prepare local minikube instance

```bash
 minikube start --driver=virtualbox
 minikube addons enable ingress
```

### (optional) Reserve a static IP address, a domain and install a certificate manager providing let's encrypt certificates on your Kubernates cluster

- If you do not have registered a domain yet, you get one for free e.g. at https://www.freenom.com
- After reserving a static IP address configure your DNS records
- Use cert-manager-nginx-controller-installer to configure your cluster as follows:

```bash
 cd cert-manager-nginx-controller-installer
# Put your registered domain and your valid e-mail address into the "env" file

# Select your cluster as kubectl context, e.g. for cluster named cluster-1
 kubectl config use-context cluster-1

# Run the script installing the cert-manager and the nginx-controller and registering the let's encrypt configuration
 ./install.sh
```

### Package and run installation script

```bash
# Enter directory ./packager
 cd ./packager

# run package.sh
# An optional argument <sha> represents a valid commit of https://github.com/cyber-dojo/versioner.
# If no argument is given, the latest version from the master branch is used.
 ./package.sh

# Enter directory packager/installer created by running script package.sh:
 cd ./installer

# Edit yml configuration files in the created installer directory in any text editor,
# There is additional information directly in the files.

# Run the script installing the cyber-dojo containers:
 ./install.sh

```
