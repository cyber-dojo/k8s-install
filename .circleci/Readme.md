
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
3. Script 1 for infra setup ie, install k3s and required sw
4. Script 2 for k3s cluster create, and deploy cyberdojo
