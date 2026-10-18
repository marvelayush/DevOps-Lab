# DevOps Lab

| | |
|---|---|
| Name | Ayush Narayan |
| USN | 1BM23IS047 |
| Branch | Information Science & Engineering |
| College | B.M.S. College of Engineering (BMSCE), Bengaluru |
| Course | DevOps |

Lab exercises based on the [DevOps Lab Manual](https://github.com/SunagP/DevOps-Lab). Each exercise folder contains its source files, a `README.md` (objective, project structure, steps with output, how it works, tech stack, result) and a `screenshots/` folder.

## Exercises

| # | Exercise | Tools |
|---|---|---|
| 1 | [Kubernetes Getting Started – Nginx Pod](Ex01-Kubernetes-Nginx-Pod/) | Minikube, kubectl |
| 2 | [Deploy a Flask App on Minikube using kubectl and YAML](Ex02-Minikube-Flask-Deployment/) | Minikube, Docker, Flask |
| 3 | [Scaling a Flask App using ReplicaSets (Flash Sale)](Ex03-ReplicaSet-Scaling-FlashSale/) | Kubernetes ReplicaSet |
| 4 | [Docker Networking with Multiple Containers](Ex04-Docker-Networking/) | Docker bridge network, MySQL, Redis |
| 5 | [Docker Security with AppArmor and Python](Ex05-Docker-Security-AppArmor/) | AppArmor, Docker SDK |
| 6 | [Real-Time Monitoring and Alerting](Ex06-Prometheus-Grafana-Monitoring/) | Prometheus, Grafana, Jenkins |
| 7 | [Jenkins Installation and Introduction to CI/CD](Ex07-Jenkins-Installation-CI/) | Jenkins |
| 8 | [Hello World Jenkins Job](Ex08-Jenkins-HelloWorld-Job/) | Jenkins Freestyle, GitHub |
| 9 | [Jenkins Multi-Stage Pipeline for a Python App](Ex09-Jenkins-MultiStage-Pipeline/) | Jenkins Pipeline, unittest |
| 10 | [Multi-Node Kubernetes Cluster with Multiple Apps](Ex10-Multi-Node-Kubernetes/) | Minikube multi-node, anti-affinity |

## Environment

- Windows 11 Home + WSL2 (Ubuntu 24.04.2 LTS, kernel 5.15.167.4-microsoft-standard-WSL2)
- Docker Desktop (Engine 29.4.1) with WSL integration
- Minikube v1.39.0 (docker driver), Kubernetes v1.37.0
- kubectl v1.34.1
- Python 3.12 (WSL)
- Jenkins in Docker (`jenkins/jenkins:lts`)

## Repository structure

```text
ExNN-<name>/
├── README.md       # steps, output, source code listings and result
├── <source files>  # app code, Dockerfiles, YAML, scripts, Jenkinsfile
└── screenshots/    # output screenshots referenced from the README
```
