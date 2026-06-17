---
title: Sample Configurations
description: Ready-to-use cluster.yaml configurations for various cluster sizes
---

# Sample Configurations

Copy any of these configurations into your `cluster.yaml` file.

---

## Minimal Cluster (1 + 1)

The smallest functional cluster — ideal for resource-constrained machines.

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
```

**Host requirements**: ~6 GB RAM, 4 CPU cores

---

## Standard Cluster (1 + 3)

The default configuration — good balance of functionality and resources.

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

  - name: "node03"
    ip: "192.168.56.13"
    memory: 1536
    cpus: 1
    role: "worker"
```

**Host requirements**: ~10 GB RAM, 6 CPU cores

---

## High-Resource Cluster (1 + 3)

For running resource-intensive workloads like databases or monitoring stacks.

```yaml
cluster:
  pod_cidr: "10.244.0.0/16"
  service_cidr: "10.96.0.0/16"
  calico_version: "v3.31.5"
  box: "ubuntu/jammy64"

nodes:
  - name: "controlplane"
    ip: "192.168.56.10"
    memory: 4096
    cpus: 2
    role: "controlplane"

  - name: "node01"
    ip: "192.168.56.11"
    memory: 4096
    cpus: 2
    role: "worker"

  - name: "node02"
    ip: "192.168.56.12"
    memory: 4096
    cpus: 2
    role: "worker"

  - name: "node03"
    ip: "192.168.56.13"
    memory: 4096
    cpus: 2
    role: "worker"
```

**Host requirements**: ~20 GB RAM, 10 CPU cores

---

## Large Cluster (1 + 5)

For testing pod scheduling, node affinity, and resource distribution.

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
    cpus: 1
    role: "worker"

  - name: "node05"
    ip: "192.168.56.15"
    memory: 2048
    cpus: 1
    role: "worker"
```

**Host requirements**: ~16 GB RAM, 8 CPU cores
