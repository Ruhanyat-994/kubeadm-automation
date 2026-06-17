---
title: Example Scenarios
description: Real-world use cases and walkthroughs
---

# Example Scenarios

Practical walkthroughs for common use cases.

---

## Scenario 1: Deploy and Verify a Web Application

Deploy a simple web server and access it from your host browser.

### Steps

```bash
# 1. Start the cluster
vagrant up

# 2. SSH into the control plane
vagrant ssh controlplane

# 3. Deploy nginx
kubectl create deployment nginx --image=nginx:alpine --replicas=3

# 4. Wait for pods to be ready
kubectl wait deployment/nginx --for=condition=Available --timeout=120s

# 5. Expose as NodePort
kubectl expose deployment nginx --port=80 --type=NodePort

# 6. Get the NodePort
kubectl get svc nginx
```

The output will show a NodePort (e.g., `31234`). Access the application at:

```
http://192.168.56.11:31234
http://192.168.56.12:31234
```

### Cleanup

```bash
kubectl delete svc nginx
kubectl delete deployment nginx
```

---

## Scenario 2: Simulate a Node Failure

Test how Kubernetes handles a worker node going offline.

### Steps

```bash
# 1. Deploy a 3-replica workload
vagrant ssh controlplane
kubectl create deployment web --image=httpd:alpine --replicas=3
kubectl wait deployment/web --for=condition=Available --timeout=120s

# 2. Check pod distribution
kubectl get pods -o wide
# Note which pods are on which nodes

# 3. From the HOST machine, halt a worker
exit
vagrant halt node02

# 4. SSH back and observe
vagrant ssh controlplane
kubectl get nodes           # node02 shows NotReady after ~40s
kubectl get pods -o wide    # After ~5 min, pods are rescheduled to other nodes

# 5. Restore the node
exit
vagrant up node02
vagrant ssh controlplane
kubectl get nodes           # node02 returns to Ready
```

---

## Scenario 3: Explore Kubernetes Namespaces

Create isolated environments using namespaces.

```bash
# Create a namespace
kubectl create namespace staging

# Deploy into the namespace
kubectl create deployment api --image=nginx:alpine -n staging --replicas=2

# List pods in the namespace
kubectl get pods -n staging

# List pods across all namespaces
kubectl get pods -A

# Clean up
kubectl delete namespace staging
```

---

## Scenario 4: Run the Built-in Test Suite

Use the included test script to validate your cluster:

```bash
vagrant ssh controlplane
sudo bash /vagrant/scripts/05-test.sh
```

This script:

1. Deploys Apache httpd with 2 replicas
2. Creates a NodePort service
3. Queries all worker node IPs
4. Prints `curl` commands and browser URLs for testing
5. Shows the full node and pod listing

---

## Scenario 5: Inspect Cluster Networking

Understand how pod networking works across nodes.

```bash
# Deploy pods on different nodes
kubectl create deployment net-test --image=nginx:alpine --replicas=4

# Wait for pods
kubectl wait deployment/net-test --for=condition=Available --timeout=120s

# See pod IPs and node placement
kubectl get pods -o wide

# Exec into a pod and test connectivity to another pod's IP
kubectl exec -it $(kubectl get pods -l app=net-test -o name | head -1) -- sh
# Inside the pod:
wget -qO- http://<OTHER_POD_IP>
exit

# Clean up
kubectl delete deployment net-test
```

This demonstrates Calico's cross-node pod networking.
