---
title: Configuration
description: Complete cluster.yaml configuration reference and examples
---

# Configuration

All cluster settings are managed through a single file: `cluster.yaml`. This page explains every configurable field.

---

## File Structure

`cluster.yaml` has two top-level sections:

```yaml
cluster:
  # Global cluster settings
  ...

nodes:
  # List of node definitions
  ...
```

---

## Cluster Section

| Field            | Type   | Default          | Description                              |
|-----------------|--------|------------------|------------------------------------------|
| `pod_cidr`      | string | `10.244.0.0/16`  | CIDR range for pod IP addresses          |
| `service_cidr`  | string | `10.96.0.0/16`   | CIDR range for Kubernetes service IPs    |
| `calico_version`| string | `v3.31.5`        | Calico CNI version to deploy             |
| `box`           | string | `ubuntu/jammy64` | Vagrant box image for all VMs            |

### Example

```yaml
cluster:
  pod_cidr: "10.244.0.0/16"
  service_cidr: "10.96.0.0/16"
  calico_version: "v3.31.5"
  box: "ubuntu/jammy64"
```

!!! warning "Pod CIDR"
    Changing `pod_cidr` from the default requires that the value matches the Calico custom resource configuration. The provisioning script handles this automatically.

---

## Nodes Section

Each node is defined as a list entry with the following fields:

| Field    | Type    | Required | Description                                      |
|----------|---------|----------|--------------------------------------------------|
| `name`   | string  | ✅       | VM hostname (must be unique)                     |
| `ip`     | string  | ✅       | Private network IP on `192.168.56.x` subnet      |
| `memory` | integer | ✅       | RAM allocation in MB                              |
| `cpus`   | integer | ✅       | Number of virtual CPUs                            |
| `role`   | string  | ✅       | Either `"controlplane"` or `"worker"`             |

### Constraints

- Exactly **one** node must have `role: "controlplane"`. The Vagrantfile validates this at startup and aborts with an error if violated.
- All other nodes must have `role: "worker"`.
- Each node must have a unique `name` and `ip`.

### Control Plane Node

```yaml
- name: "controlplane"
  ip: "192.168.56.10"
  memory: 2048          # Minimum 2048 MB recommended
  cpus: 2               # Minimum 2 CPUs required by kubeadm
  role: "controlplane"
```

!!! danger "Control Plane Resources"
    kubeadm requires at least **2 CPUs** for the control plane node. Setting `cpus: 1` will cause `kubeadm init` to fail.

### Worker Node

```yaml
- name: "node01"
  ip: "192.168.56.11"
  memory: 1536          # Minimum 1024 MB for basic workloads
  cpus: 1
  role: "worker"
```

---

## Adding Worker Nodes

To add a new worker node:

1. Copy an existing worker block
2. Change the `name` (must be unique)
3. Increment the IP address
4. Adjust `memory` and `cpus` as needed
5. Run `vagrant up`

```yaml
nodes:
  # ... existing nodes ...

  - name: "node04"
    ip: "192.168.56.14"
    memory: 2048
    cpus: 2
    role: "worker"
```

---

## Removing Worker Nodes

To remove a worker node:

1. Delete or comment out the node entry in `cluster.yaml`
2. Destroy the specific VM: `vagrant destroy node03 -f`

!!! note
    Removing a node from `cluster.yaml` does not automatically destroy its VM. You must run `vagrant destroy <name>` separately.

---

## Full Example Configuration

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
