# Exercise 1 – Kubernetes Getting Started (Nginx Pod)

## Aim
Deploy an application (Nginx, simulating Zepto's storefront web app) as a Pod on Kubernetes using Minikube, and access it from the browser.

## Tools
Minikube, kubectl, Docker

## Steps
```bash
minikube start
kubectl run hello-k8s --image=nginx --port=80
kubectl get pods
kubectl expose pod hello-k8s --type=NodePort --port=80
kubectl get svc
minikube service hello-k8s
```
All commands are also in [`commands.sh`](commands.sh).

## Output
**Minikube started**
![minikube start](screenshots/01-minikube-start.png)

**Pod running**
![kubectl get pods](screenshots/02-pod-running.png)

**Service exposed**
![kubectl get svc](screenshots/03-service.png)

**Nginx welcome page in browser**
![nginx page](screenshots/04-nginx-browser.png)

## Result
Nginx was deployed as a Pod on a local Kubernetes cluster, exposed using a NodePort Service, and accessed successfully in the browser.
