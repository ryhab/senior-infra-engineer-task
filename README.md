# Infrastructure Engineer Challenge

Hi, please look at [instructions.md](instructions.md). 


## Before deploying, run the setup script to initialize the cluster and registry:

```sh
./start-local.sh
```
This script:

*Creates a Kind cluster.
*Sets up a local Docker registry.
*Connects the cluster to the registry.
*Configures Ingress for services.

Once completed, proceed with the deployment steps below.

## Guestbook App - Kubernetes Deployment
This guide provides step-by-step instructions for deploying the Guestbook App in a Kubernetes environment using kind. The application consists of:

Frontend – A Flask web app that allows users to post messages.
Backend – A Python Flask API handling message storage.
MongoDB – A NoSQL database storing guestbook messages.

### Prerequisites
- Docker installed
- Kubernetes (`kubectl`) installed
- `kind` (for local cluster)
- Helm installed

### Steps to Run

1. **Start Kind cluster**:
```sh
   kind create cluster --name guestbook
```

**Verify the cluster is running**:
```sh
     kubectl cluster-info
```

2. **Build & Push Docker Images:**:
```sh
docker build -t localhost:5000/guestbook-backend ./src/backend
docker build -t localhost:5000/guestbook-frontend ./src/frontend
docker push localhost:5000/guestbook-backend
docker push localhost:5000/guestbook-frontend
```

3. **Deploy MongoDB, Backend, and Frontend:**:   
You can either manually deploy each service or use the provided deployment script:

```sh
./deploy.sh
```
This script:

*Builds and pushes the backend and frontend Docker images.
*Deploys MongoDB, Backend, and Frontend.
*Ensures all services are running properly.

Alternatively, you can deploy each component manually:
```sh
     kubectl apply -f src/backend/kubernetes-manifests/
     kubectl apply -f src/frontend/kubernetes-manifests/
```

4. **Verify All Running Services:**:   
 ```sh   
    kubectl get pods
    kubectl get services
 ```

**If any pod is not running, check logs:**:
 ```sh  
    kubectl logs -l tier=backend
    kubectl logs -l tier=frontend
    kubectl logs -l tier=db
 ```

5. **Port-forward services:**:  
Backend (5002):
```sh  
   Backend: kubectl port-forward svc/python-guestbook-backend 5002:5002
```

Frontend (5001):
```sh  
   Frontend: kubectl port-forward svc/python-guestbook-frontend 5001:5001
```

6. **Open the Guestbook UI:**: 
   Go to http://localhost:5001


# Troubleshooting
**Check Logs**:

Backend Logs:
```sh 
   kubectl logs -l tier=backend
```

Frontend Logs:
```sh 
   kubectl logs -l tier=frontend
```

MongoDB Logs:
```sh 
   kubectl logs -l tier=db
```

7. **Check If MongoDB Is Storing Messages**:

Enter the MongoDB pod and verify stored messages:
```sh 
   kubectl exec -it $(kubectl get pod -l tier=db -o jsonpath="{.items[0].metadata.name}") -- mongo
```

Inside the MongoDB shell, run:
```js
   use guestbook
   show collections
   db.messages.find().pretty()
```

Expected Output:
  ```json 
   [
  {
    "author": "Rihab",
    "message": "Hii",
    "date": 1740049614.0849328
  }
]

```

8. **Restart Deployments If Needed:**:
 If any service is unresponsive, restart its deployment:
 ```sh
    kubectl rollout restart deployment python-guestbook-backend
    kubectl rollout restart deployment python-guestbook-frontend
```

9. **Adding Monitoring with Prometheus & Grafana:**:
Install Prometheus & Grafana using Helm:
 ```sh
 helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
 helm repo update
 helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
 ```

10. **Verify Monitoring Stack:**:
 Check that all pods are running:
 ```sh
  kubectl get pods -n monitoring
 ```

 11. **Port-forward Grafana to access the UI:**
```sh
   kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
```

Go to http://localhost:3000 and log in with:

    Username: admin
    Password: Get it by running:

```sh
  kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode
```

12. **Configure Prometheus as a Data Source in Grafana:**:

1. Go to Settings > Data Sources
2. Add Prometheus with the URL:

http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090

13. **Setting Up Alerts in Grafana:**:
To trigger alerts when CPU usage is high:

1. Open Grafana, go to Alerting > Create Alert Rule.
2. Add a new rule with the following PromQL expression:

     rate(node_cpu_seconds_total{mode="idle"}[5m])

3. Set the threshold (e.g., when CPU usage is above 80%).
4. Choose Email/Webhook notification channels to receive alerts.
5. Save and test the alert.

14. **Triggering a High CPU Load to Test Alerts:**:
1. Run the following in a pod to simulate high CPU usage:
```sh
    kubectl run --rm -it stress --image=alpine:latest -- sh
    apk add --no-cache stress
    stress --cpu 4 --timeout 60
```
2. This will run a CPU-intensive process for 60 seconds, triggering an alert.