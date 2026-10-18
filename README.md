# DevOps Lab – Course Work

| | |
|---|---|
| **Name** | Ayush Narayan |
| **USN** | 1BM23IS047 |
| **Branch** | Information Science & Engineering |
| **College** | B.M.S. College of Engineering, Bengaluru |
| **Course** | DevOps |

Lab exercises based on the [DevOps Lab Manual](https://github.com/SunagP/DevOps-Lab). Each folder contains the source code, configuration files, the commands used, and screenshots of the output.

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

## Repository structure
```
ExNN-<name>/
├── README.md        # aim, steps, output screenshots, result
├── <source files>   # app code, Dockerfiles, YAML, Jenkinsfile
└── screenshots/     # output screenshots
```

## Environment
- Ubuntu / WSL2 with Docker
- Minikube + kubectl
- Python 3
- Jenkins (Docker image `jenkins/jenkins:lts`)
