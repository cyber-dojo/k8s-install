
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
    0) checkout the github
    1) Try running k3s agent also
        Error: 
            * Token required error
            * echo $KUBECONFIG returned nothing
    2) Read more
    3) Should we go for PLAN C wiith RKE? or switch to minikube in 


Doubts - 
Can circle CI use a singlemachine executor for all jobs in a workflow?
How many nodes are required for cyberdojo in this case? HA not reqrd ryt