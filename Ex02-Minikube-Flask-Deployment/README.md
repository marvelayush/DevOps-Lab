# Exercise 2 – Deploy a Flask App on Minikube using kubectl and YAML

## Objective

Containerise a Flask app and deploy it on Minikube with a Deployment and a NodePort Service written in YAML.

## Project Structure

```text
Ex02-Minikube-Flask-Deployment/
├── app.py                  # Flask app on port 15000
├── Dockerfile              # builds the flask-app image
├── flask-deployment.yaml   # Deployment (1 replica) + NodePort Service
├── README.md
└── screenshots/
    ├── 01-docker-build.png
    ├── 02-deployment-pods.png
    ├── 03-logs.png
    └── 04-service-curl.png
```

Source: [app.py](app.py) · [Dockerfile](Dockerfile) · [flask-deployment.yaml](flask-deployment.yaml)

## Steps

### 1. Start Minikube

```bash
minikube start --driver=docker --container-runtime=docker
```

```text
* minikube v1.39.0 on Ubuntu 24.04 (amd64)
* Starting "minikube" primary control-plane node in "minikube" cluster
* Downloading Kubernetes v1.37.0 preload ...
* Configuring bridge CNI (Container Networking Interface) ...
* Enabled addons: storage-provisioner, default-storageclass
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Started Minikube with the Docker runtime so `minikube docker-env` could be used.

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

Built `flask-app:latest` in Minikube's Docker daemon.

![docker build](screenshots/01-docker-build.png)

### 3. Deploy and verify

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

Created the Deployment and Service, and the Pod was running.

![deployment and pods](screenshots/02-deployment-pods.png)

### 4. Describe the Deployment

```bash
kubectl describe deployment flask-app
```

```text
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
NewReplicaSet:          flask-app-59f7cdccb4 (1/1 replicas created)
Events:
  Normal  ScalingReplicaSet  3s    deployment-controller  Scaled up replica set flask-app-59f7cdccb4 from 0 to 1
```

The Deployment created ReplicaSet `flask-app-59f7cdccb4`.

### 5. Check the logs

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

Flask was listening on port 15000.

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

Hello from Flask on Kubernetes!
```

Got the tunnel URL, and curl returned the Flask response.

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
docker build (Minikube's Docker) --> flask-app:latest
                                          |
kubectl apply --> Deployment --> ReplicaSet --> Pod :15000
                                                  ^
curl --> minikube tunnel --> NodePort 31009 --> Service
```

- `minikube docker-env` points the Docker CLI at the node's daemon, so the image never needs a registry.
- `imagePullPolicy: Never` makes the kubelet use that local image.
- The Deployment manages a ReplicaSet that keeps one `app=flask-app` Pod running.
- The NodePort Service selects the Pod by label and forwards port 31009 to 15000.

## Tech Stack

- Python 3.11 (`python:3.11-slim`), Flask 3.1.3
- Docker Desktop (Engine 29.4.1) on WSL2 Ubuntu 24.04
- Minikube v1.39.0 (Docker runtime), Kubernetes v1.37.0, kubectl v1.34.1

## Result

The Flask app was containerised, deployed on Minikube and exposed through a NodePort Service. It returned `Hello from Flask on Kubernetes!`.
