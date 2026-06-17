---
title: Quick Start
description: Get a Kubernetes cluster running in 5 minutes
---

# Quick Start

Get a fully functional multi-node Kubernetes cluster running on your local machine in under 5 minutes.

!!! tip "Prerequisites"
    Make sure you have [VirtualBox](prerequisites.md#virtualbox) and [Vagrant](prerequisites.md#vagrant) installed before proceeding.

---

## Step 1 — Clone the Repository

```bash
git clone https://github.com/Ruhanyat-994/kubeadm-automation.git
cd kubeadm-automation
```

---

## Step 2 — Review the Configuration

Open `cluster.yaml` to see the default cluster layout:

```yaml
cluster:
  pod_cidr: "10.244.0.0/16"
  service_cidr: "10.96.0.0/16"
  calico_version: "v3.31.5"
  box: "ubuntu/jammy64"

nodes:
  - name: "controlplane"
    ip: "192.168.56.10"
    memory: 2048
    cpus: 2
    role: "controlplane"

  - name: "node01"
    ip: "192.168.56.11"
    memory: 1536
    cpus: 1
    role: "worker"

  - name: "node02"
    ip: "192.168.56.12"
    memory: 1536
    cpus: 1
    role: "worker"
```

!!! info "Customisation"
    You can change node count, resources, and IPs here. See the [Configuration](../installation/configuration.md) guide for all options.

---

## Step 3 — Start the Cluster

```bash
vagrant up
```

This command:

1. Downloads the Ubuntu 22.04 Vagrant box (first time only)
2. Creates VirtualBox VMs for each node
3. Installs containerd, kubeadm, kubelet, and kubectl on all nodes
4. Initialises the Kubernetes control plane with kubeadm
5. Deploys Calico CNI
6. Joins worker nodes to the cluster

!!! warning "First Run"
    The first run downloads ~1 GB of packages and images. It typically takes **10–20 minutes** depending on your internet speed. Subsequent starts are much faster.

---

## Step 4 — Access the Cluster

SSH into the control plane node:

```bash
vagrant ssh controlplane
```

---

## Step 5 — Verify

Check that all nodes are ready:

```bash
kubectl get nodes
```

Expected output:

```
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   5m    v1.32.x
node01         Ready    <none>          3m    v1.32.x
node02         Ready    <none>          2m    v1.32.x
```

Check system pods:

```bash
kubectl get pods -n kube-system
```

All pods should show `Running` status.

---

## Step 6 — Deploy a Test Workload (Optional)

Run the included test script to deploy a sample Apache web server:

```bash
sudo bash /vagrant/scripts/05-test.sh
```

This deploys an `httpd` service and prints the URLs where you can access it from your host browser.

---

## What's Next?

- [Basic Usage](../usage/basic-usage.md) — Learn how to manage your cluster day-to-day
- [Configuration](../installation/configuration.md) — Customise resources, networking, and node count
- [Troubleshooting](../operations/troubleshooting.md) — Common issues and solutions
