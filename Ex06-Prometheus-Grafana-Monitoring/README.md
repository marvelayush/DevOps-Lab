# Exercise 6 – Real-Time Operations Monitoring and Alerting

## Aim
For the quick-commerce delivery platform ZAPPTTO, simulate delivery metrics with Python, scrape them with Prometheus, visualise them on a Grafana dashboard, raise alerts, and automate the stack with a Jenkins pipeline.

## Files
| File | Purpose |
|---|---|
| `delivery_metrics.py` | Exposes delivery metrics at `:8000/metrics` |
| `prometheus.yml` | Prometheus scrape config |
| `alert_rules.yml` | Alerts: `HighPendingDeliveries`, `HighAverageDeliveryTime` |
| `Dockerfile` | Image for the metrics app |
| `Dockerfile.prometheus` | Prometheus image with the config included |
| `Jenkinsfile` | Pipeline: check Docker → build → run app → run Prometheus & Grafana |

## Part A – Run manually
```bash
pip3 install prometheus-client
python3 delivery_metrics.py            # keep running
curl http://localhost:8000/metrics     # new terminal

# Prometheus (host network) with our config + alerts
docker run -d --name prometheus --network=host \
  -v ./prometheus.yml:/etc/prometheus/prometheus.yml \
  -v ./alert_rules.yml:/etc/prometheus/alert_rules.yml \
  prom/prometheus
# open http://localhost:9090 -> Status -> Targets, and Alerts

# Grafana
docker run -d --name grafana -p 3000:3000 grafana/grafana
ip addr show docker0                    # note the IP, e.g. 172.17.0.1
```
In Grafana (`http://localhost:3000`, login `admin` / `admin`, skip password change):
1. Connections → Data sources → Prometheus → URL `http://172.17.0.1:9090` → **Save & test**
2. New dashboard with 4 panels:
   - `total_deliveries`
   - `pending_deliveries`
   - `on_the_way_deliveries`
   - `average_delivery_time_sum / average_delivery_time_count`

**Simulate alerts:** change `pending = random.randint(50, 100)` in `delivery_metrics.py`, restart it and check the Alerts page.

## Part B – Jenkins pipeline
Jenkins must be able to run Docker commands. Start Jenkins with the Docker socket and install the Docker CLI inside it:
```bash
docker rm -f prometheus grafana       # stop the manual ones first
docker run -d --name jenkins -u root -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
docker exec -u root jenkins bash -c "apt-get update && apt-get install -y docker.io"
```
In Jenkins: **New Item → Pipeline** → *Pipeline script from SCM* → Git → this repo's URL → Branch `*/main` → Script Path `Ex06-Prometheus-Grafana-Monitoring/Jenkinsfile` → **Build Now**.

## Output
**Metrics endpoint**
![metrics](screenshots/01-metrics-endpoint.png)

**Prometheus targets UP**
![targets](screenshots/02-prometheus-targets.png)

**Prometheus alerts firing**
![alerts](screenshots/03-prometheus-alerts.png)

**Grafana data source saved**
![datasource](screenshots/04-grafana-datasource.png)

**Grafana delivery dashboard**
![dashboard](screenshots/05-grafana-dashboard.png)

**Jenkins pipeline success**
![jenkins](screenshots/06-jenkins-pipeline.png)

## Result
Delivery metrics were collected by Prometheus, visualised in Grafana, alerts fired when thresholds were crossed, and the full stack was deployed through a Jenkins pipeline.
