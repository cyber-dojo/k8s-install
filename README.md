# k8s-install

A Helm chart that runs a cyber-dojo server on Kubernetes.
It is the Kubernetes counterpart of [commander](https://github.com/cyber-dojo/commander),
which runs the same images under docker compose.

- [Prerequisites](#prerequisites)
- [Install](#install)
- [Try it locally](#try-it-locally)
  - [With minikube](#with-minikube)
  - [With k3s](#with-k3s)
- [What gets installed](#what-gets-installed)
- [Versions](#versions)
- [The runner](#the-runner)
- [Testing](#testing)
- [Uninstall](#uninstall)

## Prerequisites

- Kubernetes 1.29 or later. The runner's Docker daemon is a native sidecar
  (an initContainer with `restartPolicy: Always`).
- Helm 3 and curl, on the machine you install from.
- A cluster that admits privileged pods in the install namespace
  (Pod Security level `privileged`). See [The runner](#the-runner).
- An ingress controller, unless you reach nginx some other way.
- A default StorageClass, or set `saver.storageClassName` and `spooler.storageClassName`.

## Install

From a checkout of this repo, with kubectl pointing at your cluster:

```bash
bin/up.sh            # the newest cyber-dojo release
bin/up.sh 0.1.498    # a specific release
```

Running it again upgrades (or downgrades) to the release you name.
Then browse to the ingress address. With no `ingress.host` set, the ingress
answers on any host name.

Arguments after the release go to helm. To set a host name and TLS
(eg with cert-manager):

```bash
bin/up.sh 0.1.498 \
  --set ingress.host=cyber-dojo.example.com \
  --set ingress.tls.enabled=true \
  --set-string ingress.annotations.cert-manager\\.io/cluster-issuer=letsencrypt-production
```

The namespace is `cyber-dojo`, unless you set `CYBER_DOJO_NAMESPACE`.

Every setting is described in [values.yaml](chart/cyber-dojo/values.yaml).

## Try it locally

Either of these gives you a one-node cluster in Docker. Both need Docker,
kubectl and helm, and reach cyber-dojo through `kubectl port-forward`, so no
ingress controller or DNS is involved.

### With minikube

```bash
minikube start --memory=6g
bin/up.sh --wait --timeout 15m
kubectl -n cyber-dojo port-forward svc/nginx 8090:80
```

Browse to http://localhost:8090. Remove it all with `minikube delete`.

### With k3s

k3s runs in one privileged container. Its kubeconfig goes in a file of its
own, so your `~/.kube/config` is untouched.

```bash
docker run -d --privileged --name cyber-dojo-k3s \
  -p 6443:6443 rancher/k3s:v1.31.4-k3s1 server
sleep 30
docker exec cyber-dojo-k3s cat /etc/rancher/k3s/k3s.yaml > ~/.kube/k3s
export KUBECONFIG=~/.kube/k3s
bin/up.sh --wait --timeout 15m
kubectl -n cyber-dojo port-forward svc/nginx 8090:80
```

Browse to http://localhost:8090. Remove it all with `docker rm -f cyber-dojo-k3s`.

## What gets installed

| Service | Kubernetes objects | State |
|---|---|---|
| nginx | Deployment, Service, Ingress | none |
| web, creator, dashboard | Deployment, Service | none |
| differ | Deployment, Service | none |
| custom/exercises/languages-start-points | Deployment, Service | none |
| saver | StatefulSet (1 replica), Service | PersistentVolumeClaim on `/cyber-dojo` (katas and groups) |
| spooler | StatefulSet (1 replica), Service | PersistentVolumeClaim on `/sqlite` (write buffer) |
| runner | Deployment, Service | Docker daemon sidecar, see below |

saver and spooler each own their volume, and must be its only writer,
so neither can run more than one replica.

All pods share one ConfigMap, `cyber-dojo-env`, holding every service's port
and fully qualified hostname. nginx needs fully qualified names because its
`resolver` does not use resolv.conf search domains.

## Versions

A cyber-dojo release is a [versioner](https://github.com/cyber-dojo/versioner)
commit whose message starts `[RELEASE=x.y.z]`. Its `app/.env` names every
service's image, tag, digest and port, and is the same file commander uses.
`bin/up.sh` finds that commit through GitHub's commit search, downloads its
`app/.env`, and passes it to the chart as `versionerEnv`. The chart pins every
image by digest. `helm history cyber-dojo --namespace cyber-dojo` shows which
release each revision installed.

To run a different image for one service, set its `image` value, eg

```bash
--set services.web.image=cyberdojo/web:2390863
```

## The runner

The runner runs each test in its own container, which it starts through the
Docker Engine API on `/var/run/docker.sock`. Kubernetes 1.24+ nodes do not run
a Docker Engine, so the chart provides one. `runner.docker` chooses how:

- `dind` (default): each runner pod has a privileged `docker:dind` sidecar
  sharing `/var/run` with the runner. The daemon listens only on the unix
  socket, so it cannot be reached from the rest of the cluster. Its images live
  in an emptyDir, so a new runner pod pulls each language image again the first
  time a test needs it. While a pull is in progress, a test run shows as pulling.
- `hostSocket`: the runner mounts the node's own `/var/run/docker.sock`.
  Use this only on nodes where you have installed a Docker Engine yourself.

`runner.sparesPerNode` holds that many pre-started containers per runner pod,
so a test run does not wait for its container to start.

## Testing

```bash
bin/test_traffic_light_saved.sh
```

checks an installed server end to end. From inside the web pod it creates a
"Bash, bats" kata through nginx and runs its starter files through web, as a
browser does, then checks the run was red and that saver stored it.
nginx admits one kata creation a minute from one address, so allow a minute
between runs.

CI (`.github/workflows/main.yml`) runs `bin/up.sh` and this test in a fresh
kind cluster on every push, and weekly against the newest release.

## Uninstall

```bash
bin/down.sh
```

The saver and spooler PersistentVolumeClaims are kept, so the katas survive
a later `bin/up.sh`. `bin/down.sh` prints the command that deletes them.
