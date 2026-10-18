# Exercise 2 – Deploy a Flask App on Minikube using kubectl and YAML

## Aim
Set up a single-node Kubernetes cluster with Minikube and deploy a Python Flask application using a Deployment and a NodePort Service.

## Files
| File | Purpose |
|---|---|
| `app.py` | Flask app listening on port 15000 |
| `Dockerfile` | Builds the `flask-app` image |
| `flask-deployment.yaml` | Deployment (1 replica) + NodePort Service |

## Steps
```bash
minikube start

# Build the image inside Minikube's Docker daemon
eval $(minikube docker-env)
docker build -t flask-app .

# Deploy
kubectl apply -f flask-deployment.yaml

# Verify
kubectl get deployments
kubectl get pods -l app=flask-app
kubectl describe deployment flask-app
kubectl logs <pod-name>
kubectl get services

# Access (keep this terminal open, run curl in a new terminal)
minikube service flask-app-service --url
curl <url-from-above>
```

## Output
**Image built inside Minikube**
![docker build](screenshots/01-docker-build.png)

**Deployment and Pod running**
![deployment and pods](screenshots/02-deployment-pods.png)

**Pod logs showing Flask running on port 15000**
![logs](screenshots/03-logs.png)

**Service and curl response**
![curl](screenshots/04-service-curl.png)

## Result
The Flask application was containerised, deployed on Minikube as a Deployment, exposed through a NodePort Service, and returned `Hello from Flask on Kubernetes!`.
