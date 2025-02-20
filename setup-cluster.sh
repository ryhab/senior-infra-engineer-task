#!/bin/bash

# Set up a Kind cluster
kind create cluster --name guestbook-cluster

# Create a local Docker registry
docker run -d --name kind-registry -p 5000:5000 registry:2

# Connect Kind to the local registry
kubectl apply -f https://kind.sigs.k8s.io/examples/kind-with-registry.yaml

echo "Kind cluster and local registry setup completed!"