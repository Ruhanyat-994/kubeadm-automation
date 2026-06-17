---
title: Multi-node Cluster
description: Planning and deploying multi-node Kubernetes clusters
---

# Multi-node Cluster

KubeAuto is designed to provision multi-node Kubernetes clusters. This guide covers planning, configuring, and managing clusters of various sizes.

---

## Cluster Planning

### Resource Planning Table

Use this table to plan your host machine requirements:

| Cluster Size   | Nodes   | Total RAM  | Total CPUs | Host RAM Needed |
|---------------|---------|-----------|------------|-----------------|
| Minimal       | 1 CP + 1 W  | 3.5 GB  | 3        | 6 GB free       |
| Small         | 1 CP + 2 W  | 5.0 GB  | 4        | 8 GB free       |
| Default       | 1 CP + 3 W  | 6.5 GB  | 5        | 10 GB free      |
| Medium        | 1 CP + 4 W  | 8.0 GB  | 6        | 12 GB free      |
| Large         | 1 CP + 6 W  | 11.0 GB | 8        | 16 GB free      |

!!! tip
    Leave at least **2 GB RAM** and **2 CPU cores** free for your host operating system.

---

## Example: 5-Node Cluster

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
    memory: 2048
    cpus: 1
    role: "worker"

  - name: "node02"
    ip: "192.168.56.12"
    memory: 2048
    cpus: 1
    role: "worker"

  - name: "node03"
    ip: "192.168.56.13"
    memory: 2048
    cpus: 1
    role: "worker"

  - name: "node04"
    ip: "192.168.56.14"
    memory: 2048
    cpus: 2
    role: "worker"
```

---

## IP Address Assignment

Nodes use the `192.168.56.x` subnet. Follow this convention:

| IP Address       | Reserved For        |
|-----------------|---------------------|
| `192.168.56.1`  | VirtualBox host adapter |
| `192.168.56.10` | Control plane       |
| `192.168.56.11` | Worker node 1       |
| `192.168.56.12` | Worker node 2       |
| `192.168.56.13+`| Additional workers  |

!!! warning
    Each IP must be unique across all nodes. Duplicate IPs will cause network failures.

---

## Provisioning Order

Nodes are provisioned **sequentially** in the order they appear in `cluster.yaml`:

1. The control plane node must be **first** — it runs `kubeadm init` and generates the join command
2. Worker nodes run after the control plane — they poll for the join command and execute it

!!! danger "Control Plane Must Be First"
    If worker nodes are listed before the control plane in `cluster.yaml`, they will fail to join because the join command doesn't exist yet.

---

## Verifying a Multi-node Cluster

After provisioning, verify all nodes have joined:

```bash
vagrant ssh controlplane
kubectl get nodes -o wide
```

Check pod distribution across nodes:

```bash
kubectl get pods -A -o wide
```

You should see Calico pods scheduled on every node.

---

## Simulating Node Failures

Multi-node clusters are useful for testing Kubernetes resilience:

```bash
# Simulate a node crash
vagrant halt node02

# Check cluster reaction
vagrant ssh controlplane
kubectl get nodes    # node02 will show NotReady after ~40 seconds

# Restore the node
vagrant up node02
kubectl get nodes    # node02 returns to Ready after kubelet restarts
```
