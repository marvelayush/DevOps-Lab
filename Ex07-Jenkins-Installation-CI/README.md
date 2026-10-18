# Exercise 7 – Jenkins Installation and Introduction to CI/CD

## Aim
Understand Continuous Integration (CI) and install Jenkins using Docker to set up CI/CD pipelines.

## Theory
**Continuous Integration** is the practice of merging code changes into a shared repository frequently, where each change is automatically built and tested so errors are caught early.

**CI flow:** developer pushes code → CI server detects the change → build → automated tests → feedback to the developer.

**Popular CI/CD tools:** Jenkins, GitHub Actions, GitLab CI/CD, CircleCI, Travis CI, Bamboo, TeamCity, Azure Pipelines, Spinnaker, Buildkite.

**Jenkins** is an open-source automation server. Key concepts:
- **Job/Project** – a task Jenkins runs
- **Build** – one run of a job
- **Pipeline** – stages to build, test and deploy (written in a `Jenkinsfile`)
- **Plugins** – extend Jenkins (Git, Docker, Pipeline…)
- **Nodes** – machines that run jobs (controller/agents)

## Steps
```bash
docker run -d --name jenkins -u root \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

docker ps -a | grep jenkins
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
1. Open `http://localhost:8080` and paste the initial admin password.
2. Click **Install suggested plugins**.
3. Create the first admin user and finish setup.

> `-u root` and the Docker socket are added so the same Jenkins can run Python (Ex 9) and Docker (Ex 6). See [`commands.sh`](commands.sh).

## Output
**Jenkins container running**
![docker ps](screenshots/01-jenkins-container.png)

**Initial admin password**
![password](screenshots/02-initial-password.png)

**Unlock Jenkins page**
![unlock](screenshots/03-unlock-jenkins.png)

**Plugins installing**
![plugins](screenshots/04-plugins.png)

**Jenkins dashboard**
![dashboard](screenshots/05-jenkins-dashboard.png)

## Result
Jenkins was installed using Docker and is accessible at `http://localhost:8080`, ready for CI/CD jobs.
