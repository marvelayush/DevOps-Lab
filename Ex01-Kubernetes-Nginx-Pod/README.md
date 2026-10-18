# Exercise 1 – Kubernetes Getting Started (Nginx Pod)

## Objective

Run Nginx (standing in for Zepto's storefront web app) as a single Pod on a local Minikube cluster, expose it with a NodePort Service and open it in the browser.

## Environment

- OS: Windows 11 Home + WSL2 Ubuntu 24.04.2 LTS
- Docker: Docker Desktop (Engine 29.4.1)
- Minikube: v1.39.0 (docker driver)
- Kubernetes: v1.37.0
- kubectl: v1.34.1
- Container runtime inside the node: containerd (Minikube default)
- Image: `nginx` (latest)

## Steps

### 1. Start the cluster

```bash
minikube start --driver=docker
```

```text
* minikube v1.39.0 on Ubuntu 24.04 (amd64)
* Using the docker driver based on user configuration
* Using Docker driver with root privileges
! For an improved experience it's recommended to use Docker Engine instead of Docker Desktop.
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.51 ...
* Configuring CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass

! /usr/local/bin/kubectl is version 1.34.1, which may have incompatibilities with Kubernetes 1.37.0.
  - Want kubectl v1.37.0? Try 'minikube kubectl -- get pods -A'
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

A single-node cluster came up inside a Docker container and kubectl's context was switched to it.

![minikube start](screenshots/01-minikube-start.png)

### 2. Create the Pod

```bash
kubectl run hello-k8s --image=nginx --port=80
kubectl wait --for=condition=Ready pod/hello-k8s --timeout=180s
```

```text
pod/hello-k8s created
pod/hello-k8s condition met
```

`kubectl run` creates a bare Pod (no Deployment); `kubectl wait` blocks until the image is pulled and the container is ready.

### 3. Check the Pod

```bash
kubectl get pods
kubectl describe pod hello-k8s
```

```text
NAME        READY   STATUS    RESTARTS   AGE
hello-k8s   1/1     Running   0          17s
```

Relevant part of `describe`:

```text
Node:             minikube/192.168.49.2
Labels:           run=hello-k8s
Status:           Running
IP:               10.244.0.3
Containers:
  hello-k8s:
    Container ID:   containerd://a5c588b33da3c512ab9af1412f6b418ba6e73b51168be158c12b59a8e80cd307
    Image:          nginx
    Port:           80/TCP
    State:          Running
    Ready:          True
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  18s   default-scheduler  Successfully assigned default/hello-k8s to minikube
  Normal  Pulling    17s   kubelet            Pulling image "nginx"
  Normal  Pulled     2s    kubelet            Successfully pulled image "nginx" in 15.742s (15.742s including waiting). Image size: 63899853 bytes.
  Normal  Created    2s    kubelet            Container created
  Normal  Started    2s    kubelet            Container started
```

`1/1 Running` means the one container in the Pod is up. The events show the scheduler → kubelet → runtime sequence.

![kubectl get pods](screenshots/02-pod-running.png)

### 4. Expose the Pod as a NodePort Service

```bash
kubectl expose pod hello-k8s --type=NodePort --port=80
kubectl get svc
```

```text
service/hello-k8s exposed

NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
hello-k8s    NodePort    10.100.38.188   <none>        80:30258/TCP   1s
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        17m
```

Port 80 of the Pod is now reachable on port 30258 of the node. The Service picks the Pod using the `run=hello-k8s` label.

![kubectl get svc](screenshots/03-service.png)

### 5. Open it in the browser

```bash
minikube service hello-k8s
```

```text
┌───────────┬───────────┬─────────────┬───────────────────────────┐
│ NAMESPACE │   NAME    │ TARGET PORT │            URL            │
├───────────┼───────────┼─────────────┼───────────────────────────┤
│ default   │ hello-k8s │ 80          │ http://192.168.49.2:30258 │
└───────────┴───────────┴─────────────┴───────────────────────────┘
* Starting tunnel for service hello-k8s.
┌───────────┬───────────┬─────────────┬────────────────────────┐
│ NAMESPACE │   NAME    │ TARGET PORT │          URL           │
├───────────┼───────────┼─────────────┼────────────────────────┤
│ default   │ hello-k8s │             │ http://127.0.0.1:34041 │
└───────────┴───────────┴─────────────┴────────────────────────┘
* Opening service default/hello-k8s in default browser...
  http://127.0.0.1:34041
! Because you are using a Docker driver on linux, the terminal needs to be open to run it.
```

The node IP 192.168.49.2 is not routable from Windows, so Minikube opened a tunnel on `127.0.0.1:34041`. That URL showed the Nginx welcome page.

![nginx page](screenshots/04-nginx-browser.png)

### 6. Clean up

```bash
kubectl delete svc hello-k8s
kubectl delete pod hello-k8s
```

```text
service "hello-k8s" deleted from default namespace
pod "hello-k8s" deleted from default namespace
```

## How It Works

```text
kubectl run ──> API server ──> etcd (desired state stored)
                    │
                    v
               scheduler ──> picks node "minikube"
                    │
                    v
               kubelet ──> containerd ──> nginx container (10.244.0.3:80)
                                               ^
browser ──> 127.0.0.1:34041 (minikube tunnel) ──> NodePort 30258 ──> Service hello-k8s
```

- kubectl only talks to the API server; the API server writes the Pod object to etcd.
- The scheduler assigns the Pod to a node, and the kubelet on that node asks the container runtime to pull and start the image.
- A NodePort Service opens the same port (30000–32767 range) on every node and forwards it to Pods matching its selector.
- With the docker driver on WSL2 the node runs inside a container, so `minikube service` has to tunnel the NodePort to localhost.

## Commands Used

```bash
minikube start --driver=docker
kubectl run hello-k8s --image=nginx --port=80
kubectl get pods
kubectl describe pod hello-k8s
kubectl expose pod hello-k8s --type=NodePort --port=80
kubectl get svc
minikube service hello-k8s
kubectl delete svc hello-k8s
kubectl delete pod hello-k8s
```

## Observations

- Minikube warned about version skew: kubectl 1.34.1 against a 1.37.0 server. The basic commands used here all worked anyway.
- Pulling the `nginx` image took about 15.7 s, which was most of the Pod's start-up time.
- Minikube v1.39 used containerd as the node runtime by default (`containerd://` in the container ID).
- The `minikube service` tunnel only works while that terminal stays open.

## Viva Questions

**Q1. What is a Pod?**
The smallest deployable unit in Kubernetes: one or more containers that share a network namespace (one IP) and storage volumes.

**Q2. What is the difference between `kubectl run` and a Deployment?**
`kubectl run` creates one bare Pod. If that Pod is deleted it is not recreated. A Deployment manages a ReplicaSet that keeps the requested number of Pods running.

**Q3. Why was a Service needed?**
Pod IPs are internal to the cluster and change when Pods are recreated. A Service gives a stable endpoint, and the NodePort type also exposes it outside the cluster.

**Q4. What are the NodePort range and the port fields?**
NodePorts come from 30000–32767. `port` is the Service port, `targetPort` is the container port, and `nodePort` is the port opened on each node.

**Q5. What does Minikube do?**
It runs a single-node (or multi-node) Kubernetes cluster locally, here as a Docker container, for development and learning.

## Result

Nginx ran as a Pod on a local Minikube cluster (Kubernetes v1.37.0). It was exposed through a NodePort Service on port 30258, and the welcome page loaded in the browser through the Minikube tunnel at `http://127.0.0.1:34041`.
