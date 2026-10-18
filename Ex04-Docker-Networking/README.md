# Exercise 4 – Docker Networking with Multiple Containers

## Objective

Connect a Flask API, MySQL and Redis on a user-defined bridge network and check that the containers reach each other by name.

## Project Structure

```text
Ex04-Docker-Networking/
├── app.py             # Flask REST API, /about on port 5001
├── requirements.txt   # Flask 3.0.3
├── Dockerfile         # builds flask-api (python:3.9-slim + ping)
├── commands.sh        # all commands for this exercise
├── README.md
└── screenshots/
    ├── 01-network-create-ls.png
    ├── 02-network-inspect.png
    ├── 03-docker-ps.png
    ├── 04-curl-about.png
    └── 05-ping.png
```

Source: [app.py](app.py) · [requirements.txt](requirements.txt) · [Dockerfile](Dockerfile) · [commands.sh](commands.sh)

## Steps

### 1. Create the bridge network

```bash
docker network create --driver bridge my-bridge-net
docker network ls
```

```text
9e054bd7e6f51f7ecc66e1d37ae17a13be63e0bb9e596c5f329d83245b6a951f

NETWORK ID     NAME            DRIVER    SCOPE
4c21e8fe02d2   bridge          bridge    local
1247a1060d23   host            host      local
b8619f3f253a   minikube        bridge    local
9e054bd7e6f5   my-bridge-net   bridge    local
6e638db5c915   none            null      local
```

Created `my-bridge-net` with the bridge driver.

![network ls](screenshots/01-network-create-ls.png)

### 2. Build the Flask image

```bash
docker build -t flask-api .
```

```text
#5 [1/6] FROM docker.io/library/python:3.9-slim
#6 [2/6] RUN apt-get update && apt-get install -y --no-install-recommends iputils-ping && rm -rf /var/lib/apt/lists/*
#7 [3/6] WORKDIR /app
#8 [4/6] COPY requirements.txt .
#9 [5/6] COPY app.py .
#10 [6/6] RUN pip install --no-cache-dir -r requirements.txt
#10 5.347 Successfully installed Flask-3.0.3 Jinja2-3.1.6 MarkupSafe-3.0.4 Werkzeug-3.1.9 blinker-1.9.0 click-8.1.8 importlib-metadata-8.7.1 itsdangerous-2.2.0 zipp-3.23.1
#11 naming to docker.io/library/flask-api:latest done
```

Built `flask-api` with `ping` installed for the connectivity test.

### 3. Run the three containers on the network

```bash
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=root mysql:latest
docker run -d --name redis --net=my-bridge-net redis:latest
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api
```

```text
Status: Downloaded newer image for mysql:latest
9f0cb30fe41c252bd6d4dfab69550575cdccc0a449cdc5e534940c2190d2eb73
Status: Downloaded newer image for redis:latest
d8acb2119fa1b4cd503b18314792e93fac8c805dd2c00201d468ce59e18595d7
845ed1234d3c271c0515fa61b47cf0a55c1f703fd959e29c1df73c283a13e9e6
```

Started MySQL, Redis and Flask on `my-bridge-net`. Only Flask is published to the host.

### 4. Inspect the network

```bash
docker network inspect my-bridge-net
```

```text
"Driver": "bridge",
"Config": [
    {
        "Subnet": "172.18.0.0/16",
        "Gateway": "172.18.0.1"
    }
],
"Containers": {
    "845ed1234d3c...": { "Name": "flask", "IPv4Address": "172.18.0.4/16" },
    "9f0cb30fe41c...": { "Name": "mysql", "IPv4Address": "172.18.0.2/16" },
    "d8acb2119fa1...": { "Name": "redis", "IPv4Address": "172.18.0.3/16" }
}
```

All three containers got addresses from the 172.18.0.0/16 subnet.

![inspect](screenshots/02-network-inspect.png)

### 5. Check the running containers

```bash
docker ps
```

```text
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                         NAMES
845ed1234d3c   flask-api      "python app.py"          9 seconds ago    Up 8 seconds    0.0.0.0:5001->5001/tcp, [::]:5001->5001/tcp   flask
d8acb2119fa1   redis:latest   "docker-entrypoint.s…"   9 seconds ago    Up 9 seconds    6379/tcp                                      redis
9f0cb30fe41c   mysql:latest   "docker-entrypoint.s…"   19 seconds ago   Up 18 seconds   3306/tcp, 33060/tcp                           mysql
```

All three containers were up.

![docker ps](screenshots/03-docker-ps.png)

### 6. Call the Flask API from the host

```bash
curl http://localhost:5001/about
```

```text
{"description":"This is a simple REST API built with Flask.","name":"Simple REST API","version":"1.0"}
```

The API answered on the published port 5001.

![curl](screenshots/04-curl-about.png)

### 7. Ping MySQL and Redis by name

```bash
docker exec -it flask ping -c 3 mysql
docker exec -it flask ping -c 3 redis
```

```text
PING mysql (172.18.0.2) 56(84) bytes of data.
64 bytes from mysql.my-bridge-net (172.18.0.2): icmp_seq=1 ttl=64 time=1.95 ms
64 bytes from mysql.my-bridge-net (172.18.0.2): icmp_seq=2 ttl=64 time=0.091 ms
64 bytes from mysql.my-bridge-net (172.18.0.2): icmp_seq=3 ttl=64 time=0.107 ms
--- mysql ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2082ms

PING redis (172.18.0.3) 56(84) bytes of data.
64 bytes from redis.my-bridge-net (172.18.0.3): icmp_seq=1 ttl=64 time=1.24 ms
64 bytes from redis.my-bridge-net (172.18.0.3): icmp_seq=2 ttl=64 time=0.094 ms
64 bytes from redis.my-bridge-net (172.18.0.3): icmp_seq=3 ttl=64 time=0.099 ms
--- redis ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2027ms
```

Container names resolved to their IPs, with no packet loss.

![ping](screenshots/05-ping.png)

### 8. Clean up

```bash
docker stop mysql redis flask && docker rm mysql redis flask
docker network rm my-bridge-net
```

```text
mysql
redis
flask
mysql
redis
flask
my-bridge-net
```

Stopped and removed the containers and the network.

## How It Works

```text
host --> localhost:5001 (-p 5001:5001)
               |
   ------------+------------ my-bridge-net 172.18.0.0/16
   |           |           |
 flask       mysql       redis
172.18.0.4  172.18.0.2  172.18.0.3
   |
   +-- "ping mysql" --> Docker DNS (127.0.0.11) --> 172.18.0.2
```

- A user-defined bridge network gives its containers a private subnet and a gateway on the host.
- Docker's embedded DNS server resolves container names on user-defined networks, so `mysql` and `redis` work as hostnames. The default `bridge` network does not do this.
- `--net` attaches a container to the network at start-up.
- Only ports published with `-p` are reachable from the host. MySQL and Redis stayed internal.

## Tech Stack

- Docker Desktop (Engine 29.4.1) on WSL2 Ubuntu 24.04
- Python 3.9 (`python:3.9-slim`), Flask 3.0.3
- MySQL 26.7.0 (`mysql:latest`), Redis 8.10.2 (`redis:latest`)

## Result

Flask, MySQL and Redis were connected on a custom bridge network. The containers reached each other by name, and the Flask API was accessible from the host on port 5001.
