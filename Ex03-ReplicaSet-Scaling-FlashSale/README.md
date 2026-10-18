# Exercise 3 – Scaling a Flask App on a Single Node using ReplicaSets

## Objective

Simulate a flash sale by running several identical Pods with a ReplicaSet, scaling them up, and checking that deleted Pods are replaced.

## Project Structure

```text
Ex03-ReplicaSet-Scaling-FlashSale/
├── app.py                      # flash-sale API: /, /buy, /health
├── Dockerfile                  # builds flashsale:1.0 with gunicorn
├── flashsale-replicaset.yaml   # ReplicaSet (3 replicas, probes) + ClusterIP Service
├── README.md
└── screenshots/
    ├── 01-rs-3-replicas.png
    ├── 02-scaled-5.png
    ├── 03-self-healing.png
    └── 04-pods-wide.png
```

Source: [app.py](app.py) · [Dockerfile](Dockerfile) · [flashsale-replicaset.yaml](flashsale-replicaset.yaml)

## Steps

### 1. Start a fresh cluster

```bash
minikube stop && minikube delete
minikube start --nodes=1 --driver=docker --container-runtime=docker
kubectl get nodes
```

```text
* Removed all traces of the "minikube" cluster.
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   6s    v1.37.0
```

Recreated the cluster with one node.

### 2. Build the image

```bash
eval $(minikube docker-env)
docker build -t flashsale:1.0 .
```

```text
#8 [4/4] RUN pip install --no-cache-dir flask gunicorn
#8 5.232 Successfully installed blinker-1.9.0 click-8.5.0 flask-3.1.3 gunicorn-26.2.0 itsdangerous-2.2.0 jinja2-3.1.6 markupsafe-3.0.4 werkzeug-3.1.9
#9 naming to docker.io/library/flashsale:1.0 done
```

Built `flashsale:1.0` in Minikube's Docker daemon.

### 3. Create the ReplicaSet

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

The ReplicaSet started 3 Pods.

![rs 3](screenshots/01-rs-3-replicas.png)

### 4. Scale to 5 replicas

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

Scaled up, and 2 new Pods were added.

![rs 5](screenshots/02-scaled-5.png)

### 5. Delete a Pod

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

The ReplicaSet replaced the deleted Pod with `flashsale-rs-4kc6c`. Deleting `flashsale-rs-d9f9c` gave the same result, with `flashsale-rs-vkppk` as the replacement.

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

All 5 Pods ran on the single node, each with its own IP.

![wide](screenshots/04-pods-wide.png)

### 7. Send requests to the Service

```bash
kubectl run curl-test --restart=Never --image=curlimages/curl -- sh -c 'for i in 1 2 3 4 5 6 7 8; do curl -s http://flashsale-svc/buy; echo; done'
kubectl logs curl-test
```

```text
{"item":"Shoes","served_by_pod":"flashsale-rs-lljs4","status":"success","time":"10:51:25","user":"user281"}
{"item":"Laptop","served_by_pod":"flashsale-rs-vkppk","status":"success","time":"10:51:25","user":"user236"}
{"item":"Shoes","served_by_pod":"flashsale-rs-g9ncz","status":"success","time":"10:51:25","user":"user783"}
{"item":"Laptop","served_by_pod":"flashsale-rs-vkppk","status":"success","time":"10:51:25","user":"user676"}
{"item":"Laptop","served_by_pod":"flashsale-rs-g9ncz","status":"success","time":"10:51:25","user":"user402"}
{"item":"Laptop","served_by_pod":"flashsale-rs-lljs4","status":"success","time":"10:51:25","user":"user945"}
```

Sent requests from inside the cluster, and the Service spread them across Pods. Through `kubectl port-forward svc/flashsale-svc 8080:80`, every request went to `flashsale-rs-g9ncz`, because port-forward connects to a single Pod.

### 8. Clean up

```bash
kubectl delete -f flashsale-replicaset.yaml
```

```text
replicaset.apps "flashsale-rs" deleted from default namespace
service "flashsale-svc" deleted from default namespace
```

Deleted the ReplicaSet and the Service.

## How It Works

```text
ReplicaSet (desired = 5)
     | watches Pods with app=flashsale
     v
Pod  Pod  Pod  Pod  Pod   <-- missing Pod is recreated
  \   |    |    |   /
   Service flashsale-svc (:80 -> :5000)
```

- The ReplicaSet controller compares the desired count with the matching Pods and creates or removes Pods to close the gap.
- `kubectl scale` only changes the desired count.
- The readiness probe on `/health` keeps a new Pod out of the Service until it responds.
- The ClusterIP Service load-balances across all ready Pods.

## Tech Stack

- Python 3.11, Flask 3.1.3, gunicorn 26.2.0
- Docker Desktop (Engine 29.4.1) on WSL2 Ubuntu 24.04
- Minikube v1.39.0 (1 node, Docker runtime), Kubernetes v1.37.0

## Result

The flash-sale app was scaled from 3 to 5 replicas with a ReplicaSet. Deleted Pods were replaced automatically, and the Service shared the load across Pods.
