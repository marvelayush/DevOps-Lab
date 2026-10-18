#!/bin/bash
# Exercise 1 - Deploy Nginx as a Pod on Kubernetes (Minikube)

minikube start

# Create the pod
kubectl run hello-k8s --image=nginx --port=80

# Verify it is running
kubectl get pods
kubectl describe pod hello-k8s

# Expose the pod as a NodePort service
kubectl expose pod hello-k8s --type=NodePort --port=80
kubectl get svc

# Open in browser (keep this terminal open)
minikube service hello-k8s

# Cleanup (after screenshots)
# kubectl delete svc hello-k8s
# kubectl delete pod hello-k8s
