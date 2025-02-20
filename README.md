# Infrastructure Engineer Challenge

Hi, please look at [instructions.md](instructions.md). 

## Guestbook App - Kubernetes Deployment
This guide provides step-by-step instructions for deploying the Guestbook App in a Kubernetes environment using kind. The application consists of:

Frontend – A Flask web app that allows users to post messages.
Backend – A Python Flask API handling message storage.
MongoDB – A NoSQL database storing guestbook messages.

### Prerequisites
- Docker installed
- Kubernetes (`kubectl`) installed
- `kind` (for local cluster)

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