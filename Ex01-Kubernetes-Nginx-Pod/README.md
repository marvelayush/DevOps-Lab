# Exercise 1 – Kubernetes Getting Started (Nginx Pod)

## Objective

Deploy Nginx (simulating Zepto's storefront web app) as a Pod on Minikube, expose it with a NodePort Service and access it from the browser.

## Environment

- OS: Windows 11 Home + WSL2 Ubuntu 24.04.2 LTS
- Docker: Docker Desktop (Engine 29.4.1)
- Minikube: v1.39.0 (docker driver)
- Kubernetes: v1.37.0
- kubectl: v1.34.1
- Container runtime: containerd
- Image: `nginx`

## Steps

### 1. Start Minikube

```bash
minikube start --driver=docker
```

```text
* minikube v1.39.0 on Ubuntu 24.04 (amd64)
* Using the docker driver based on user configuration
* Using Docker driver with root privileges
* Starting "minikube" primary control-plane node in "minikube" cluster
* Pulling base image v0.0.51 ...
* Configuring CNI (Container Networking Interface) ...
* Verifying Kubernetes components...
  - Using image gcr.io/k8s-minikube/storage-provisioner:v5
* Enabled addons: storage-provisioner, default-storageclass
! /usr/local/bin/kubectl is version 1.34.1, which may have incompatibilities with Kubernetes 1.37.0.
* Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

Started a single-node cluster and kubectl was configured to use it.

![minikube start](screenshots/01-minikube-start.png)

### 2. Create the Pod

```bash
kubectl run hello-k8s --image=nginx --port=80
```

```text
pod/hello-k8s created
```

Created a Pod named `hello-k8s` from the nginx image.

### 3. Verify the Pod

```bash
kubectl get pods
kubectl describe pod hello-k8s
```

```text
NAME        READY   STATUS    RESTARTS   AGE
hello-k8s   1/1     Running   0          17s
```

```text
Node:             minikube/192.168.49.2
Status:           Running
IP:               10.244.0.3
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  18s   default-scheduler  Successfully assigned default/hello-k8s to minikube
  Normal  Pulling    17s   kubelet            Pulling image "nginx"
  Normal  Pulled     2s    kubelet            Successfully pulled image "nginx" in 15.742s (15.742s including waiting). Image size: 63899853 bytes.
  Normal  Created    2s    kubelet            Container created
  Normal  Started    2s    kubelet            Container started
```

The Pod reached `1/1 Running` on node `minikube`.

![kubectl get pods](screenshots/02-pod-running.png)

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

Exposed port 80 of the Pod on NodePort 30258.

![kubectl get svc](screenshots/03-service.png)

### 5. Access the application

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

Opened `http://127.0.0.1:34041` in the browser and the Nginx welcome page loaded.

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
kubectl
   |
   v
API Server --> etcd
   |
   v
Scheduler --> node "minikube"
   |
   v
Kubelet --> containerd --> nginx container (port 80)
                                ^
browser --> minikube tunnel --> NodePort 30258 --> Service hello-k8s
```

- kubectl sends the request to the API server, which stores the Pod in etcd.
- The scheduler assigns the Pod to a node and the kubelet starts the container through the runtime.
- The NodePort Service forwards traffic from port 30258 on the node to port 80 of the Pod.
- With the docker driver, `minikube service` tunnels the NodePort to `127.0.0.1` so the browser can reach it.

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

## Result

Nginx was deployed as a Pod on Minikube, exposed using a NodePort Service and accessed in the browser at `http://127.0.0.1:34041`.
