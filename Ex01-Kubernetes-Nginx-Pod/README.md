# Exercise 1 – Kubernetes Getting Started (Nginx Pod)

## Objective

Deploy Nginx (simulating Zepto's storefront web app) as a Pod on Minikube, expose it with a NodePort Service and open it in the browser.

## Project Structure

```text
Ex01-Kubernetes-Nginx-Pod/
├── commands.sh      # all kubectl / minikube commands used
├── README.md
└── screenshots/
    ├── 01-minikube-start.png
    ├── 02-pod-running.png
    ├── 03-service.png
    └── 04-nginx-browser.png
```

Source: [commands.sh](commands.sh)

## Steps

### 1. Start Minikube

```bash
minikube start --driver=docker
```

```text
* minikube v1.39.0 on Ubuntu 24.04 (amd64)
* Using the docker driver based on user configuration
* Starting "minikube" primary control-plane node in "minikube" cluster
* Configuring CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
* Enabled addons: storage-provisioner, default-storageclass
! /usr/local/bin/kubectl is version 1.34.1, which may have incompatibilities with Kubernetes 1.37.0.
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Started a single-node cluster.

![minikube start](screenshots/01-minikube-start.png)

### 2. Create the Pod

```bash
kubectl run hello-k8s --image=nginx --port=80
kubectl get pods
```

```text
pod/hello-k8s created

NAME        READY   STATUS    RESTARTS   AGE
hello-k8s   1/1     Running   0          17s
```

Created the `hello-k8s` Pod, and it reached `Running`.

![kubectl get pods](screenshots/02-pod-running.png)

### 3. Describe the Pod

```bash
kubectl describe pod hello-k8s
```

```text
Node:             minikube/192.168.49.2
Status:           Running
IP:               10.244.0.3
Events:
  Normal  Scheduled  18s   default-scheduler  Successfully assigned default/hello-k8s to minikube
  Normal  Pulling    17s   kubelet            Pulling image "nginx"
  Normal  Pulled     2s    kubelet            Successfully pulled image "nginx" in 15.742s
  Normal  Created    2s    kubelet            Container created
  Normal  Started    2s    kubelet            Container started
```

Checked the node, Pod IP and start-up events.

### 4. Expose the Pod

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

Exposed the Pod on NodePort 30258.

![kubectl get svc](screenshots/03-service.png)

### 5. Open in the browser

```bash
minikube service hello-k8s
```

```text
* Starting tunnel for service hello-k8s.
┌───────────┬───────────┬─────────────┬────────────────────────┐
│ NAMESPACE │   NAME    │ TARGET PORT │          URL           │
├───────────┼───────────┼─────────────┼────────────────────────┤
│ default   │ hello-k8s │             │ http://127.0.0.1:34041 │
└───────────┴───────────┴─────────────┴────────────────────────┘
! Because you are using a Docker driver on linux, the terminal needs to be open to run it.
```

Opened `http://127.0.0.1:34041` and the Nginx welcome page loaded.

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

Deleted the Service and the Pod.

## How It Works

```text
kubectl --> API Server --> etcd
                |
            Scheduler --> node "minikube"
                |
             Kubelet --> containerd --> nginx :80
                                          ^
browser --> minikube tunnel --> NodePort 30258 --> Service
```

- kubectl sends the request to the API server, which stores the Pod in etcd.
- The scheduler picks a node and the kubelet starts the container through the runtime.
- The NodePort Service forwards node port 30258 to port 80 of the Pod.
- With the docker driver, `minikube service` tunnels the NodePort to `127.0.0.1`.

## Tech Stack

- Minikube v1.39.0 (docker driver), Kubernetes v1.37.0, kubectl v1.34.1
- Docker Desktop (Engine 29.4.1) on WSL2 Ubuntu 24.04
- Nginx (latest image)

## Result

Nginx ran as a Pod on Minikube, was exposed with a NodePort Service and opened in the browser at `http://127.0.0.1:34041`.
