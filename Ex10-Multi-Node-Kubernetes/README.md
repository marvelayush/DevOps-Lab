# Exercise 10 – Multi-Node Kubernetes Cluster with Multiple Applications

## Aim
Deploy two backend services of an e-commerce platform – Product Catalog (2 replicas) and Shopping Cart (3 replicas) – on a 3-node Minikube cluster, with each replica placed on a different node for high availability.

## Files
| File | Purpose |
|---|---|
| `product_catalog.py` | `GET /products` |
| `shopping_cart.py` | `GET /cart`, `POST /cart` |
| `Dockerfile.product`, `Dockerfile.shopping` | Images for both apps |
| `product_catalog_deployment.yaml` | 2 replicas with pod anti-affinity |
| `shopping_cart_deployment.yaml` | 3 replicas with pod anti-affinity |
| `product_catalog_service.yaml`, `shopping_cart_service.yaml` | NodePort Services |

## Steps
```bash
# Clean up and start a 3-node cluster
minikube stop; minikube delete --all
minikube start --nodes 3 -p devops-multinode
kubectl get nodes

# Build images and load them into every node
docker build -t product-catalog:latest -f Dockerfile.product .
docker build -t shopping-cart:latest -f Dockerfile.shopping .
minikube -p devops-multinode image load product-catalog:latest
minikube -p devops-multinode image load shopping-cart:latest
minikube -p devops-multinode image ls | grep -E "product|shopping"

# Deploy and expose
kubectl apply -f product_catalog_deployment.yaml
kubectl apply -f shopping_cart_deployment.yaml
kubectl apply -f product_catalog_service.yaml
kubectl apply -f shopping_cart_service.yaml

# Verify distribution across nodes
kubectl get deployments
kubectl get pods -o wide

# Access (each in its own terminal, keep them open)
minikube -p devops-multinode service product-catalog-service --url
minikube -p devops-multinode service shopping-cart-service --url

curl <product-url>/products
curl <cart-url>/cart
curl -X POST <cart-url>/cart -H "Content-Type: application/json" -d '{"id": 1, "name": "Laptop", "quantity": 1}'
```
> If you run as root, add `--force` to `minikube start`.

## Output
**3 nodes Ready**
![nodes](screenshots/01-nodes.png)

**Images loaded into the cluster**
![images](screenshots/02-images-loaded.png)

**Pods spread across different nodes (`-o wide`)**
![pods wide](screenshots/03-pods-wide.png)

**Services**
![services](screenshots/04-services.png)

**curl – products, cart, add to cart**
![curl](screenshots/05-curl-tests.png)

## Result
Both services were deployed on a multi-node cluster with replicas placed on separate nodes using pod anti-affinity, and were accessed successfully through NodePort Services.

> Note: each Shopping Cart replica keeps its own in-memory cart, so a `GET /cart` routed to a different replica may return a different list. A real system would use a shared store such as Redis.
