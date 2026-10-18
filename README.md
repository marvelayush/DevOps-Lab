# DevOps Lab

| | |
|---|---|
| Name | Ayush Narayan |
| USN | 1BM23IS047 |
| Branch | Information Science & Engineering (ISE) |
| College | B.M.S. College of Engineering (BMSCE), Bengaluru |
| Course | DevOps |

Lab exercises based on the [DevOps Lab Manual](https://github.com/SunagP/DevOps-Lab/tree/main/Exercises). Every exercise folder contains its source files, a `README.md` and a `screenshots/` folder. Each README has: Objective, Use Case, Architecture, Environment, Project Structure, numbered Steps with the real command output and the screenshot for that step, How It Works, Key Configuration, Commands Used, Problems Faced, and Result.

Companion repository for the Jenkins exercises: **[marvelayush/devops-sample-code](https://github.com/marvelayush/devops-sample-code)**. Jenkins checks out this repository in Exercise 8 (`hello-world.sh`) and Exercise 9 (Flask app + `Jenkinsfile`). Copies of those files are kept in the Ex08 and Ex09 folders.

## Exercises

| # | Exercise | Tools | Screenshots |
|---|---|---|---|
| 1 | [Kubernetes Getting Started – Nginx Pod](Ex01-Kubernetes-Nginx-Pod/) | Minikube, kubectl, NodePort Service | 5 |
| 2 | [Deploy a Flask App on Minikube using kubectl and YAML](Ex02-Minikube-Flask-Deployment/) | Minikube, Docker, Flask, Deployment + NodePort | 9 |
| 3 | [Scaling a Flask App using ReplicaSets (Flash Sale)](Ex03-ReplicaSet-Scaling-FlashSale/) | ReplicaSet, probes, gunicorn, Docker Hub | 13 |
| 4 | [Docker Networking with Multiple Containers](Ex04-Docker-Networking/) | Docker bridge network, Flask, MySQL, Redis | 11 |
| 5 | [Docker Security with AppArmor and Python](Ex05-Docker-Security-AppArmor/) | AppArmor, Docker SDK for Python, container hardening | 12 |
| 6 | [Real-Time Monitoring and Alerting](Ex06-Prometheus-Grafana-Monitoring/) | Prometheus, Grafana, alert rules, Jenkins pipeline | 23 |
| 7 | [Introduction to CI and Jenkins Installation](Ex07-Jenkins-Installation-CI/) | Jenkins (Docker), setup wizard, plugins | 15 |
| 8 | [Hello World Jenkins Job](Ex08-Jenkins-HelloWorld-Job/) | GitHub, git, Jenkins Freestyle job | 14 |
| 9 | [Jenkins Multi-Stage Pipeline for a Python App](Ex09-Jenkins-MultiStage-Pipeline/) | Jenkins Pipeline (Jenkinsfile), Flask, unittest | 19 |
| 10 | [Multi-Node Kubernetes Cluster with Multiple Apps](Ex10-Multi-Node-Kubernetes/) | Minikube 3 nodes, pod anti-affinity, NodePort | 24 |
| | **Total** | | **145** |

## Environment

- Windows 11 Home + WSL2 Ubuntu 24.04.2 LTS (kernel 5.15.167.4-microsoft-standard-WSL2)
- Docker Desktop (Engine 29.4.1) with WSL integration
- Minikube v1.39.0 (docker driver), Kubernetes v1.37.0, kubectl v1.34.1
- Python 3.12 in WSL (virtual environments for pip installs)
- Jenkins 2.580.1 LTS in Docker (`jenkins/jenkins:lts`)
- Prometheus 3.15.0, Grafana 13.2.4
- GitHub (`marvelayush`), Docker Hub (`friction2004`)

Docker Desktop specifics used across the lab: `host.docker.internal` instead of the Linux-only `172.17.0.1` (Ex06), `minikube service` tunnels to reach NodePorts (Ex01–02, Ex10), and AppArmor not being available on WSL2 (Ex05).

## Repository structure

```text
ExNN-<name>/
├── README.md         # objective, architecture, steps with real output, how it works, key configuration, ...
├── <source files>    # app code, Dockerfiles, Kubernetes YAML, scripts, Jenkinsfile, configs
└── screenshots/      # NN-<what-it-shows>.png, numbered in the order they appear in the README
```
