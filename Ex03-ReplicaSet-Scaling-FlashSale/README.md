# Exercise 3 – Scaling a Flask App on a Single Node using ReplicaSets

## Objective

Run several identical Pods of a Flask app with a ReplicaSet, scale them up, and check that Kubernetes replaces a Pod when it is deleted. Then send requests through a Service to see them shared across the Pods.

## Use Case

During a Flipkart Big Billion Days style flash sale, traffic to the checkout API jumps within minutes. Running more copies of the same app behind one Service lets the store absorb the spike, and self-healing keeps the copy count steady if one crashes.

## Environment

- Windows 11 Home + WSL2 Ubuntu 24.04.2 LTS
- Docker Desktop (Engine 29.4.1)
- Minikube v1.39.0 (docker driver, Docker runtime, 1 node)
- Kubernetes v1.37.0
- kubectl v1.34.1
- Base image `python:3.11-slim`, Flask 3.1.3, gunicorn 26.2.0

## Project Structure

```text
Ex03-ReplicaSet-Scaling-FlashSale/
├── app.py                      # flash-sale API: /, /buy, /health (returns the Pod name)
├── Dockerfile                  # builds flashsale:1.0, served by gunicorn on port 5000
├── flashsale-replicaset.yaml   # ReplicaSet (3 replicas, probes, limits) + ClusterIP Service
├── README.md
└── screenshots/
    ├── 01-rs-3-replicas.png
    ├── 02-scaled-5.png
    ├── 03-self-healing.png
    ├── 04-pods-wide.png
    ├── 05-port-forward.png
    ├── 06-buy-browser.png
    ├── 07-health-browser.png
    └── 08-load-balancing.png
```

Source: [app.py](app.py) · [Dockerfile](Dockerfile) · [flashsale-replicaset.yaml](flashsale-replicaset.yaml)

## Steps

### 1. Start a fresh single-node cluster

```bash
minikube stop && minikube delete
minikube start --nodes=1 --driver=docker --container-runtime=docker
kubectl get nodes
```

```text
* 1 node stopped.
* Removed all traces of the "minikube" cluster.
* minikube v1.39.0 on Ubuntu 24.04 (amd64)
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   6s    v1.37.0
```

Deleted the old cluster and started a clean one with one node.

### 2. Build the image inside Minikube

```bash
eval $(minikube docker-env)
docker build -t flashsale:1.0 .
docker images flashsale
```

```text
#4 [1/4] FROM docker.io/library/python:3.11-slim
#6 [2/4] WORKDIR /app
#7 [3/4] COPY app.py .
#8 [4/4] RUN pip install --no-cache-dir flask gunicorn
#8 5.232 Successfully installed blinker-1.9.0 click-8.5.0 flask-3.1.3 gunicorn-26.2.0 itsdangerous-2.2.0 jinja2-3.1.6 markupsafe-3.0.4 werkzeug-3.1.9
#9 naming to docker.io/library/flashsale:1.0 done

IMAGE           ID             DISK USAGE   CONTENT SIZE   EXTRA
flashsale:1.0   a8aa6f385c29        143MB             0B
```

Built `flashsale:1.0` in Minikube's Docker daemon.

### 3. Create the ReplicaSet and Service

```bash
kubectl apply -f flashsale-replicaset.yaml
kubectl get rs
kubectl get pods
```

```text
replicaset.apps/flashsale-rs created
service/flashsale-svc created

NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   3         3         3       21s

NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-c7qlw   1/1     Running   0          21s
flashsale-rs-d9f9c   1/1     Running   0          21s
flashsale-rs-g9ncz   1/1     Running   0          21s
```

The ReplicaSet started 3 Pods, and all of them passed the readiness probe.

![rs 3](screenshots/01-rs-3-replicas.png)

### 4. Scale up for the sale

```bash
kubectl scale rs flashsale-rs --replicas=5
kubectl get rs
kubectl get pods
```

```text
replicaset.apps/flashsale-rs scaled

NAME           DESIRED   CURRENT   READY   AGE
flashsale-rs   5         5         5       2m46s

NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-c7qlw   1/1     Running   0          2m46s
flashsale-rs-d9f9c   1/1     Running   0          2m46s
flashsale-rs-g9ncz   1/1     Running   0          2m46s
flashsale-rs-lljs4   1/1     Running   0          16s
flashsale-rs-rz4j6   1/1     Running   0          16s
```

Scaled from 3 to 5 replicas, and 2 new Pods were added.

![rs 5](screenshots/02-scaled-5.png)

### 5. Delete a Pod (self-healing)

```bash
kubectl delete pod flashsale-rs-c7qlw
kubectl get pods
```

```text
pod "flashsale-rs-c7qlw" deleted from default namespace

NAME                 READY   STATUS    RESTARTS   AGE
flashsale-rs-4kc6c   0/1     Running   0          3s
flashsale-rs-d9f9c   1/1     Running   0          5m3s
flashsale-rs-g9ncz   1/1     Running   0          5m3s
flashsale-rs-lljs4   1/1     Running   0          2m33s
flashsale-rs-rz4j6   1/1     Running   0          2m33s
```

The ReplicaSet created `flashsale-rs-4kc6c` right away to get back to 5. It showed `0/1` until its readiness probe passed. Deleting `flashsale-rs-d9f9c` worked the same way, with `flashsale-rs-vkppk` as the replacement.

![self healing](screenshots/03-self-healing.png)

### 6. Check Pod placement

```bash
kubectl get pods -o wide
```

```text
NAME                 READY   STATUS    RESTARTS   AGE     IP           NODE
flashsale-rs-4kc6c   1/1     Running   0          88s     10.244.0.8   minikube
flashsale-rs-g9ncz   1/1     Running   0          6m28s   10.244.0.4   minikube
flashsale-rs-lljs4   1/1     Running   0          3m58s   10.244.0.7   minikube
flashsale-rs-rz4j6   1/1     Running   0          3m58s   10.244.0.6   minikube
flashsale-rs-vkppk   1/1     Running   0          54s     10.244.0.9   minikube
```

All 5 Pods ran on the single `minikube` node, each with its own IP.

![wide](screenshots/04-pods-wide.png)

### 7. Send requests through the Service

I re-applied the ReplicaSet, scaled it to 5 (Pods `2j6g9`, `5llr5`, `fxn2c`, `xbh6d`, `xzkcm`) and forwarded the Service to my machine:

```bash
kubectl port-forward svc/flashsale-svc 8080:80
```

```text
Forwarding from 127.0.0.1:8080 -> 5000
Forwarding from [::1]:8080 -> 5000
Handling connection for 8080
Handling connection for 8080
```

![port-forward](screenshots/05-port-forward.png)

Opened the API in the browser:

```text
http://localhost:8080/buy
{"item":"Headphones","served_by_pod":"flashsale-rs-fxn2c","status":"success","time":"11:48:30","user":"user733"}

http://localhost:8080/health
{"pod":"flashsale-rs-fxn2c","status":"healthy"}
```

![buy](screenshots/06-buy-browser.png)

![health](screenshots/07-health-browser.png)

Port-forward always connects to a single Pod, so I used an in-cluster test to show load balancing:

```bash
kubectl run lb-test --rm -i --restart=Never --image=curlimages/curl -- sh -c 'for i in 1 2 3 4 5 6 7 8; do curl -s http://flashsale-svc/buy; echo; done'
```

```text
{"item":"Headphones","served_by_pod":"flashsale-rs-2j6g9","status":"success","time":"11:56:24","user":"user844"}
{"item":"Shoes","served_by_pod":"flashsale-rs-2j6g9","status":"success","time":"11:56:24","user":"user421"}
{"item":"Headphones","served_by_pod":"flashsale-rs-5llr5","status":"success","time":"11:56:24","user":"user804"}
{"item":"Shoes","served_by_pod":"flashsale-rs-2j6g9","status":"success","time":"11:56:24","user":"user522"}
{"item":"Shoes","served_by_pod":"flashsale-rs-xzkcm","status":"success","time":"11:56:24","user":"user383"}
{"item":"Laptop","served_by_pod":"flashsale-rs-2j6g9","status":"success","time":"11:56:24","user":"user293"}
{"item":"Headphones","served_by_pod":"flashsale-rs-2j6g9","status":"success","time":"11:56:24","user":"user794"}
{"item":"Smartphone","served_by_pod":"flashsale-rs-5llr5","status":"success","time":"11:56:24","user":"user19"}
```

The Service sent the 8 requests to 3 different Pods.

![load balancing](screenshots/08-load-balancing.png)

### 8. Clean up

```bash
kubectl delete -f flashsale-replicaset.yaml
```

```text
replicaset.apps "flashsale-rs" deleted from default namespace
service "flashsale-svc" deleted from default namespace
```

Deleted the ReplicaSet (its Pods went with it) and the Service.

## How It Works

```text
kubectl apply / kubectl scale
      |
      v
API Server --> etcd (ReplicaSet: replicas = 5)
      |
      v
ReplicaSet controller: counts Pods with app=flashsale
      |  fewer than 5? create Pod objects
      v
Scheduler --> node "minikube"
      |
      v
Kubelet --> Docker runtime --> flashsale containers (gunicorn :5000)
      |
      +-- readiness /health ok --> Pod added to Service endpoints
      +-- liveness  /health fails --> container restarted

client --> flashsale-svc :80 --> kube-proxy picks a ready Pod --> Pod :5000
```

- The ReplicaSet controller keeps comparing desired and actual Pod counts. Deleting a Pod makes the count drop, so a new one is created.
- `kubectl scale` only changes `replicas` in etcd. The controller does the actual work.
- A Pod only receives traffic after its readiness probe passes, which is why the new Pod showed `0/1` for a few seconds.
- kube-proxy spreads new connections to the Service across all ready endpoints.

## Key Configuration

- `replicas: 3`: the desired number of Pods, changed to 5 at runtime with `kubectl scale`.
- `selector.matchLabels: app: flashsale` + template label `app: flashsale`: the ReplicaSet owns every Pod with this label. They must match, or the ReplicaSet is rejected.
- `readinessProbe` on `/health` (every 5 s): decides whether the Pod is added to the Service. `livenessProbe` on `/health` (every 10 s, after 10 s): restarts the container if it stops answering.
- `resources.requests` (100m CPU, 128Mi) and `limits` (500m, 256Mi): requests are what the scheduler reserves; limits cap what the container may use.
- Service `port: 80` → `targetPort: 5000`, `type: ClusterIP`: clients use port 80 inside the cluster, and traffic goes to gunicorn on 5000.
- `gunicorn -b 0.0.0.0:5000 app:app --workers 1 --threads 2`: a production WSGI server instead of Flask's dev server.
- `imagePullPolicy: Never`: uses the image built inside Minikube.

## Commands Used

```bash
minikube stop && minikube delete
minikube start --nodes=1 --driver=docker --container-runtime=docker
kubectl get nodes
eval $(minikube docker-env)
docker build -t flashsale:1.0 .
docker images flashsale
kubectl apply -f flashsale-replicaset.yaml
kubectl get rs
kubectl get pods
kubectl scale rs flashsale-rs --replicas=5
kubectl delete pod flashsale-rs-c7qlw
kubectl get pods -o wide
kubectl port-forward svc/flashsale-svc 8080:80
curl http://localhost:8080/buy
curl http://localhost:8080/health
kubectl run lb-test --rm -i --restart=Never --image=curlimages/curl -- sh -c 'for i in 1 2 3 4 5 6 7 8; do curl -s http://flashsale-svc/buy; echo; done'
kubectl delete -f flashsale-replicaset.yaml
```

## Problems Faced

- Through `kubectl port-forward`, every `/buy` request returned the same `served_by_pod`, because port-forward attaches to one Pod and bypasses Service load balancing. I ran the requests from a curl Pod inside the cluster instead, which went through the Service.

## Result

The flash-sale app was scaled from 3 to 5 replicas with a ReplicaSet. Deleted Pods were replaced automatically, and the ClusterIP Service shared requests across the Pods.
