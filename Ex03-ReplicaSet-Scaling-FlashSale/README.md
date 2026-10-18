# Exercise 3 – Scaling a Flask App on a Single Node using ReplicaSets

## Aim
Simulate an e-commerce flash sale: run multiple identical Pods of a Flask app using a ReplicaSet, scale them up, and observe self-healing when a Pod is deleted.

## Files
| File | Purpose |
|---|---|
| `app.py` | Flash-sale API (`/`, `/buy`, `/health`) that reports which Pod served the request |
| `Dockerfile` | Builds `flashsale:1.0` with gunicorn |
| `flashsale-replicaset.yaml` | ReplicaSet (3 replicas, readiness/liveness probes) + ClusterIP Service |

## Steps
```bash
# Fresh single-node cluster
minikube stop && minikube delete
minikube start --nodes=1
kubectl get nodes

# Build image inside Minikube's Docker daemon
eval $(minikube docker-env)
docker build -t flashsale:1.0 .

# Create the ReplicaSet + Service
kubectl apply -f flashsale-replicaset.yaml
kubectl get rs
kubectl get pods

# Scale up for the flash sale
kubectl scale rs flashsale-rs --replicas=5
kubectl get rs
kubectl get pods

# Self-healing: delete one pod and watch it come back
kubectl delete pod <any-flashsale-pod-name>
kubectl get pods
kubectl get pods -o wide

# (Optional) see load spread across pods
kubectl port-forward svc/flashsale-svc 8080:80
curl http://localhost:8080/buy     # run a few times, "served_by_pod" changes
```

## Output
**ReplicaSet with 3 pods**
![rs 3](screenshots/01-rs-3-replicas.png)

**Scaled to 5 replicas**
![rs 5](screenshots/02-scaled-5.png)

**Pod deleted and automatically replaced**
![self healing](screenshots/03-self-healing.png)

**Pod distribution (`-o wide`)**
![wide](screenshots/04-pods-wide.png)

## Observations
- Initial replicas: 3. After scaling: 5.
- Deleting a Pod makes the ReplicaSet create a new one immediately to keep the desired count.
- All Pods run on the single `minikube` node.

## Result
The flash-sale app was scaled horizontally using a ReplicaSet, and Kubernetes maintained the desired number of replicas automatically.
