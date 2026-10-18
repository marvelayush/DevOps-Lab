#!/bin/bash
# Exercise 7 - Install Jenkins with Docker

# Run Jenkins (as root + Docker socket so later exercises can use python3 and docker)
docker run -d --name jenkins -u root \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

docker ps -a | grep jenkins

# Initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Open http://localhost:8080 -> paste password -> Install suggested plugins -> create admin user

# Tools needed by Exercises 6 and 9 (run once)
docker exec -u root jenkins bash -c "apt-get update && apt-get install -y python3 python3-venv python3-pip docker.io"
