
Plan A
Initial attempt was to run Docker executor in circleCI with K3d (Dockerised version of k3s), create k3d cluster and run cyberdojo implemnetation

Errors
Docker daemon was not running - changed docker image to docker-dind
Dockerdind needs to be run as privileged
CircleCI do not provide option to run docker executors as privileged
Machine executor needs to be adopted

Plan B - Machine executor
Rather than gong for docker and k3d in machine executor, lets try a basic machine image and instal k3s in it. 

Steps:
1. Circle CI config- machine executor
2. Update script
3. Script 1 for infra setup ie, install k3s and helm
4. Script 2 for k3s cluster create, and deploy cyberdojo
5. Script to wait until deployment and check for all cyberdojo services were up

Errors - k3s cluster created and server process is running. but no resources are available.
    1) Try running k3s agent also
        Error: 
            * Token required error
            * echo $KUBECONFIG returned nothing
            * token added but connection refused errors
    2) Read more
    3) use INSTALL_K3S_EXEC="--write-kubeconfig-mode 664" - one node created

Now that node is created lets try cyber dojo implementation

Remember to optimise config.yaml and all scripts