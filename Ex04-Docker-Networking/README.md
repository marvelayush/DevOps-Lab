# Exercise 4 – Docker Networking with Multiple Containers

## Aim
Understand Docker networking by connecting three containers (Flask API, MySQL, Redis) on a user-defined bridge network and verifying they can reach each other by name.

## Files
| File | Purpose |
|---|---|
| `app.py` | Flask REST API with `/about` on port 5001 |
| `requirements.txt` | Python dependencies |
| `Dockerfile` | Builds `flask-api` (includes `ping` for testing) |
| `commands.sh` | All commands for Tasks 1–6 |

## Steps
```bash
docker network create --driver bridge my-bridge-net
docker network ls
docker network inspect my-bridge-net

docker build -t flask-api .
docker run -d --name mysql --net=my-bridge-net -e MYSQL_ROOT_PASSWORD=root mysql:latest
docker run -d --name redis --net=my-bridge-net redis:latest
docker run -d --name flask --net=my-bridge-net -p 5001:5001 flask-api
docker ps
curl http://localhost:5001/about

docker exec -it flask ping -c 3 mysql
docker exec -it flask ping -c 3 redis

docker stop mysql redis flask && docker rm mysql redis flask
docker network rm my-bridge-net
```

## Output
**Bridge network created and listed**
![network ls](screenshots/01-network-create-ls.png)

**Network inspect (with containers attached)**
![inspect](screenshots/02-network-inspect.png)

**All three containers running**
![docker ps](screenshots/03-docker-ps.png)

**Flask API response**
![curl](screenshots/04-curl-about.png)

**Ping mysql and redis from the flask container**
![ping](screenshots/05-ping.png)

## Questions
1. **Purpose of `--net`?** It connects the container to the given network.
2. **How do containers on the same network talk?** By container name (Docker's built-in DNS) or IP address.
3. **Bridge vs host network?** Bridge gives containers an isolated private network; host shares the host's network stack directly.
4. **Expose a port to the host?** With `-p host_port:container_port`, e.g. `-p 5001:5001`.

## Result
Three containers were connected on a custom bridge network and communicated successfully using container names.
