#!/bin/bash
# Exercise 4 - Docker networking with Flask + MySQL + Redis

# Task 1-3: create, list and inspect a bridge network
docker network create --driver bridge my-bridge-net
docker network ls
docker network inspect my-bridge-net

# Task 4: build the Flask image and launch all three containers on the network
docker build -t flask-api .
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=root mysql:latest
docker run -d --name redis --net=my-bridge-net redis:latest
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api
docker ps

# Containers are now attached to the network
docker network inspect my-bridge-net

# Flask API from the host
curl http://localhost:5001/about

# Task 5: test connectivity by container name (DNS on the bridge network)
docker exec -it flask ping -c 3 mysql
docker exec -it flask ping -c 3 redis

# Task 6: cleanup
docker stop mysql redis flask && docker rm mysql redis flask
docker network rm my-bridge-net
