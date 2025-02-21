#!/bin/bash

# Build backend and frontend Docker images with correct ports
docker build -t localhost:5000/guestbook-backend ./src/backend
docker build -t localhost:5000/guestbook-frontend ./src/frontend

# Push images to the local registry
docker push localhost:5000/guestbook-backend
docker push localhost:5000/guestbook-frontend

# Deploy MongoDB
kubectl apply -f src/backend/kubernetes-manifests/guestbook-mongodb.deployment.yaml
kubectl apply -f src/backend/kubernetes-manifests/guestbook-mongodb.service.yaml

# Deploy Backend with the correct port (5002)
kubectl apply -f src/backend/kubernetes-manifests/guestbook-backend.deployment.yaml
kubectl apply -f src/backend/kubernetes-manifests/guestbook-backend.service.yaml

# Deploy Frontend with the correct port (5001)
kubectl apply -f src/frontend/kubernetes-manifests/guestbook-frontend.deployment.yaml
kubectl apply -f src/frontend/kubernetes-manifests/guestbook-frontend.service.yaml

echo "Deployment completed!"