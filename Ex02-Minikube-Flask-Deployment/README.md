# Exercise 2 – Deploy a Flask App on Minikube using kubectl and YAML

## Objective

Containerise a Python Flask application and deploy it on a single-node Minikube cluster using a Deployment and a NodePort Service defined in YAML.

## Environment

- OS: Windows 11 Home + WSL2 Ubuntu 24.04.2 LTS
- Docker: Docker Desktop (Engine 29.4.1)
- Minikube: v1.39.0 (docker driver)
- Kubernetes: v1.37.0
- kubectl: v1.34.1
- Container runtime: Docker
- Base image: `python:3.11-slim`, Flask 3.1.3

## Steps

### 1. Files created

app.py

```python
from flask import Flask

app = Flask(__name__)


@app.route('/')
def home():
    return "Hello from Flask on Kubernetes!"


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=15000)
```

Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY app.py /app/
RUN pip install --no-cache-dir flask
EXPOSE 15000
CMD ["python", "app.py"]
```

flask-deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      containers:
      - name: flask-app
        image: flask-app:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 15000
---
apiVersion: v1
kind: Service
metadata:
  name: flask-app-service
spec:
  selector:
    app: flask-app
  ports:
  - port: 15000
    targetPort: 15000
  type: NodePort
```

Created the Flask app, its Dockerfile and the Kubernetes manifest.

### 2. Start Minikube

```bash
minikube start --driver=docker --container-runtime=docker
```

```text
* minikube v1.39.0 on Ubuntu 24.04 (amd64)
* Using the docker driver based on user configuration
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.51 ...
* Downloading Kubernetes v1.37.0 preload ...
* Configuring bridge CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
! /usr/local/bin/kubectl is version 1.34.1, which may have incompatibilities with Kubernetes 1.37.0.
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Started Minikube with the Docker runtime so that `minikube docker-env` can be used.

### 3. Build the image inside Minikube

```bash
eval $(minikube docker-env)
docker build -t flask-app .
docker images flask-app
```

```text
#5 [1/4] FROM docker.io/library/python:3.11-slim@sha256:e88e9763f943ec1834f992a4b51e0f24500486803e8bc534e5767af9ea65f6ce
#5 DONE 13.4s
#6 [2/4] WORKDIR /app
#6 DONE 4.2s
#7 [3/4] COPY app.py /app/
#7 DONE 0.2s
#8 [4/4] RUN pip install --no-cache-dir flask
#8 5.110 Successfully installed blinker-1.9.0 click-8.5.0 flask-3.1.3 itsdangerous-2.2.0 jinja2-3.1.6 markupsafe-3.0.4 werkzeug-3.1.9
#8 DONE 5.7s
#9 exporting to image
#9 writing image sha256:2b94609d85b748c4352d19d3482a5b43d20699acd2b47b09ac0850a5b2889969 done
#9 naming to docker.io/library/flask-app 0.0s done
#9 DONE 0.4s

IMAGE              ID             DISK USAGE   CONTENT SIZE   EXTRA
flask-app:latest   2b94609d85b7        141MB             0B
```

Built the `flask-app` image directly in Minikube's Docker daemon, so no registry push was needed.

![docker build](screenshots/01-docker-build.png)

### 4. Deploy the application

```bash
kubectl apply -f flask-deployment.yaml
```

```text
deployment.apps/flask-app created
service/flask-app-service created
```

Created the Deployment and the Service from the YAML file.

### 5. Verify the Deployment and Pod

```bash
kubectl get deployments
kubectl get pods -l app=flask-app
kubectl describe deployment flask-app
```

```text
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
flask-app   1/1     1            1           2s

NAME                         READY   STATUS    RESTARTS   AGE
flask-app-59f7cdccb4-7cn74   1/1     Running   0          2s
```

```text
Name:                   flask-app
Selector:               app=flask-app
Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
StrategyType:           RollingUpdate
Pod Template:
  Labels:  app=flask-app
  Containers:
   flask-app:
    Image:         flask-app:latest
    Port:          15000/TCP
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
NewReplicaSet:   flask-app-59f7cdccb4 (1/1 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  3s    deployment-controller  Scaled up replica set flask-app-59f7cdccb4 from 0 to 1
```

The Deployment created ReplicaSet `flask-app-59f7cdccb4` and its Pod was running.

![deployment and pods](screenshots/02-deployment-pods.png)

### 6. Check the Pod logs

```bash
kubectl logs flask-app-59f7cdccb4-7cn74
```

```text
 * Serving Flask app 'app'
 * Debug mode: off
WARNING: This is a development server. Do not use it in a production deployment. Use a production WSGI server instead.
 * Running on all addresses (0.0.0.0)
 * Running on http://127.0.0.1:15000
 * Running on http://10.244.0.3:15000
Press CTRL+C to quit
```

Flask was listening on port 15000 inside the Pod.

![logs](screenshots/03-logs.png)

### 7. Access the Service

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

Got the tunnel URL from Minikube and the curl request returned the Flask response.

![curl](screenshots/04-service-curl.png)

### 8. Clean up

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
docker build (Minikube's Docker) --> image flask-app:latest
                                          |
kubectl apply --> Deployment --> ReplicaSet --> Pod (flask-app:15000)
                                                   ^
curl --> minikube tunnel --> NodePort 31009 --> Service flask-app-service
```

- `eval $(minikube docker-env)` points the Docker CLI at the daemon inside the Minikube node, so the image is available to the cluster directly.
- `imagePullPolicy: Never` makes the kubelet use the local image instead of pulling from Docker Hub.
- The Deployment creates a ReplicaSet, which keeps one Pod with the label `app=flask-app` running.
- The NodePort Service selects Pods by that label and forwards port 31009 on the node to port 15000 in the container.

## Commands Used

```bash
minikube start --driver=docker --container-runtime=docker
eval $(minikube docker-env)
docker build -t flask-app .
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

## Result

The Flask application was containerised, deployed on Minikube as a Deployment, exposed through a NodePort Service and returned `Hello from Flask on Kubernetes!`.
