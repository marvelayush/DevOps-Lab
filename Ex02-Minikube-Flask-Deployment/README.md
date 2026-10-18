# Exercise 2 – Deploy a Flask App on Minikube using kubectl and YAML

## Objective

Set up a single-node Kubernetes cluster with Minikube and deploy a Python Flask app with a Deployment and a NodePort Service written in YAML. The image was built inside Minikube, so no registry was needed.

## Environment

- Windows 11 Home + WSL2 Ubuntu 24.04.2 LTS
- Docker Desktop (Engine 29.4.1)
- Minikube v1.39.0 (docker driver, Docker container runtime)
- Kubernetes v1.37.0
- kubectl v1.34.1
- Base image `python:3.11-slim`, Flask 3.1.3

## Project Structure

```text
Ex02-Minikube-Flask-Deployment/
├── app.py                  # Flask app, returns a message on / at port 15000
├── Dockerfile              # builds the flask-app image
├── flask-deployment.yaml   # Deployment (1 replica) + NodePort Service
├── README.md
└── screenshots/
    ├── 01-docker-build.png
    ├── 02-deployment-pods.png
    ├── 03-logs.png
    ├── 04-service-curl.png
    ├── 05-minikube-status.png
    └── 06-service-url.png
```

Source: [app.py](app.py) · [Dockerfile](Dockerfile) · [flask-deployment.yaml](flask-deployment.yaml)

## Steps

### 1. Start Minikube

```bash
minikube start --driver=docker --container-runtime=docker
minikube status
kubectl cluster-info
```

```text
* minikube v1.39.0 on Ubuntu 24.04 (amd64)
* Starting "minikube" primary control-plane node in "minikube" cluster
* Configuring bridge CNI (Container Networking Interface) ...
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

Kubernetes control plane is running at https://127.0.0.1:55645
CoreDNS is running at https://127.0.0.1:55645/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

Started Minikube with the Docker runtime and checked that the control plane and CoreDNS were running.

![minikube status](screenshots/05-minikube-status.png)

### 2. Build the image inside Minikube

```bash
eval $(minikube docker-env)
docker build -t flask-app .
docker images flask-app
```

```text
#5 [1/4] FROM docker.io/library/python:3.11-slim
#6 [2/4] WORKDIR /app
#7 [3/4] COPY app.py /app/
#8 [4/4] RUN pip install --no-cache-dir flask
#8 5.110 Successfully installed blinker-1.9.0 click-8.5.0 flask-3.1.3 itsdangerous-2.2.0 jinja2-3.1.6 markupsafe-3.0.4 werkzeug-3.1.9
#9 naming to docker.io/library/flask-app 0.0s done

IMAGE              ID             DISK USAGE   CONTENT SIZE   EXTRA
flask-app:latest   2b94609d85b7        141MB             0B
```

Pointed the Docker CLI at Minikube's daemon and built `flask-app:latest` there.

![docker build](screenshots/01-docker-build.png)

### 3. Deploy the app

```bash
kubectl apply -f flask-deployment.yaml
kubectl get deployments
kubectl get pods -l app=flask-app
```

```text
deployment.apps/flask-app created
service/flask-app-service created

NAME        READY   UP-TO-DATE   AVAILABLE   AGE
flask-app   1/1     1            1           2s

NAME                         READY   STATUS    RESTARTS   AGE
flask-app-59f7cdccb4-7cn74   1/1     Running   0          2s
```

Created the Deployment and Service from one YAML file. The Pod was running.

![deployment and pods](screenshots/02-deployment-pods.png)

### 4. Describe the Deployment

```bash
kubectl describe deployment flask-app
```

```text
Selector:               app=flask-app
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Containers:
   flask-app:
    Image:         flask-app:latest
    Port:          15000/TCP
NewReplicaSet:   flask-app-59f7cdccb4 (1/1 replicas created)
Events:
  Normal  ScalingReplicaSet  3s    deployment-controller  Scaled up replica set flask-app-59f7cdccb4 from 0 to 1
```

The Deployment controller created ReplicaSet `flask-app-59f7cdccb4` with one Pod.

### 5. Check the Pod logs

```bash
kubectl logs flask-app-59f7cdccb4-7cn74
```

```text
 * Serving Flask app 'app'
 * Debug mode: off
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:15000
 * Running on http://10.244.0.3:15000
Press CTRL+C to quit
```

Flask was listening on port 15000 on all interfaces of the Pod.

![logs](screenshots/03-logs.png)

### 6. Access the Service

```bash
kubectl get services
minikube service flask-app-service --url
curl http://127.0.0.1:34067
```

```text
NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
flask-app-service   NodePort    10.97.148.200   <none>        15000:31009/TCP   14m
kubernetes          ClusterIP   10.96.0.1       <none>        443/TCP           28m

http://127.0.0.1:34067
! Because you are using a Docker driver on linux, the terminal needs to be open to run it.

Hello from Flask on Kubernetes!
```

Ran `minikube service --url` in a separate terminal to keep the tunnel open, then curl returned the app's response.

![service url](screenshots/06-service-url.png)

![curl](screenshots/04-service-curl.png)

### 7. Clean up

```bash
kubectl delete -f flask-deployment.yaml
```

```text
deployment.apps "flask-app" deleted from default namespace
service "flask-app-service" deleted from default namespace
```

Deleted the Deployment and the Service.

## How It Works

```text
eval $(minikube docker-env) + docker build  -->  flask-app:latest in the node's Docker
                                                         |
kubectl apply -f flask-deployment.yaml                   |
      |                                                  |
      v                                                  |
API Server --> etcd (Deployment + Service stored)        |
      |                                                  |
      v                                                  |
Deployment controller --> ReplicaSet --> Pod object      |
      |                                                  |
      v                                                  |
Scheduler --> node "minikube"                            |
      |                                                  |
      v                                                  v
Kubelet --> Docker runtime --> uses local image --> Flask container :15000

curl --> 127.0.0.1 tunnel --> NodePort 31009 --> flask-app-service :15000 --> Pod :15000
```

- `minikube docker-env` exports `DOCKER_HOST` so the build runs on the Minikube node, where the kubelet can see the image.
- The Deployment controller creates a ReplicaSet, and the ReplicaSet creates the Pod. The scheduler places it and the kubelet starts it.
- The Service finds the Pod through the `app=flask-app` label and forwards traffic to it.
- With the Docker driver on WSL2, the NodePort is only reachable through the `minikube service` tunnel.

## Key Configuration

- `imagePullPolicy: Never`: the kubelet uses the locally built `flask-app:latest` and never tries Docker Hub. Without it, the `latest` tag would trigger a pull that fails.
- `containerPort: 15000`: documents the port the Flask container listens on.
- `port` vs `targetPort`: `port: 15000` is the Service's own port inside the cluster. `targetPort: 15000` is the container port traffic is sent to.
- `type: NodePort` vs ClusterIP: NodePort also opens a port on the node (31009, picked automatically) so traffic from outside the cluster can reach the Service. ClusterIP is internal only.
- `---`: separates two Kubernetes objects in one YAML file, so one `kubectl apply` created both.
- `host='0.0.0.0'` in `app.py`: Flask listens on all interfaces. With the default `127.0.0.1`, the Service could not reach it.

## Commands Used

```bash
minikube start --driver=docker --container-runtime=docker
minikube status
kubectl cluster-info
eval $(minikube docker-env)
docker build -t flask-app .
docker images flask-app
kubectl apply -f flask-deployment.yaml
kubectl get deployments
kubectl get pods -l app=flask-app
kubectl describe deployment flask-app
kubectl logs flask-app-59f7cdccb4-7cn74
kubectl get services
minikube service flask-app-service --url
curl http://127.0.0.1:34067
kubectl delete -f flask-deployment.yaml
```

## Problems Faced

- Minikube v1.39 used containerd as the default runtime, so `eval $(minikube docker-env)` reported it as experimental and there was no Docker daemon to build into. I deleted the cluster and recreated it with `--container-runtime=docker`.
- When the commands were sent from PowerShell, it expanded `$(minikube docker-env)` itself before bash saw it. I ran the commands directly in a bash (WSL) shell instead.

## Result

The Flask app was built into an image inside Minikube, deployed as a Deployment and exposed through a NodePort Service. A request through the Minikube tunnel returned `Hello from Flask on Kubernetes!`.
