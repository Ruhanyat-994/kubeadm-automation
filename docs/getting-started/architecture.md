---
title: Architecture
description: Cluster architecture, network topology, and provisioning sequence
---

# Architecture

This page explains the architecture of a KubeAuto-provisioned cluster, including the VM topology, network design, and provisioning sequence.

---

## Cluster Topology

```mermaid
graph TB
    subgraph "Host Machine"
        VB["VirtualBox + Vagrant"]
    end

    subgraph "Private Network — 192.168.56.0/24"
        CP["controlplane<br/>192.168.56.10<br/>2 GB RAM · 2 CPUs"]
        W1["node01<br/>192.168.56.11<br/>1.5 GB RAM · 1 CPU"]
        W2["node02<br/>192.168.56.12<br/>1.5 GB RAM · 1 CPU"]
        W3["node03<br/>192.168.56.13<br/>1.5 GB RAM · 1 CPU"]
    end

    VB -->|vagrant up| CP
    VB -->|vagrant up| W1
    VB -->|vagrant up| W2
    VB -->|vagrant up| W3

    CP -->|kubeadm join| W1
    CP -->|kubeadm join| W2
    CP -->|kubeadm join| W3

    style CP fill:#009688,stroke:#00796b,color:#fff
    style W1 fill:#26a69a,stroke:#00897b,color:#fff
    style W2 fill:#26a69a,stroke:#00897b,color:#fff
    style W3 fill:#26a69a,stroke:#00897b,color:#fff
```

---

## Network Architecture

KubeAuto configures three network layers:

### 1. Host-Only Network (Node-to-Node)

A VirtualBox private network on `192.168.56.x`. This is the primary network for inter-node communication and API server access.

### 2. Pod Network (Container-to-Container)

Calico CNI overlay network on `10.244.0.0/16`. Every pod gets a unique IP from this range. Calico handles routing between pods across nodes using BGP.

### 3. Service Network (Service Discovery)

Kubernetes ClusterIP service range on `10.96.0.0/16`. Used internally by kube-proxy for service load balancing.

```mermaid
graph LR
    subgraph "Node Network — 192.168.56.0/24"
        N1["controlplane<br/>.10"]
        N2["node01<br/>.11"]
        N3["node02<br/>.12"]
    end

    subgraph "Pod Network — 10.244.0.0/16"
        P1["Pod A<br/>10.244.1.5"]
        P2["Pod B<br/>10.244.2.8"]
        P3["Pod C<br/>10.244.3.2"]
    end

    subgraph "Service Network — 10.96.0.0/16"
        S1["Service<br/>10.96.0.10"]
    end

    N2 --- P1
    N3 --- P2
    N3 --- P3
    S1 -.->|load balance| P1
    S1 -.->|load balance| P2

    style S1 fill:#7c4dff,stroke:#6200ea,color:#fff
```

---

## Component Stack

Each VM runs the following software stack:

| Layer             | Component                  | Notes                          |
|------------------|---------------------------|--------------------------------|
| Operating System | Ubuntu 22.04 LTS (Jammy)  | Vagrant box `ubuntu/jammy64`   |
| Container Runtime| containerd                 | SystemdCgroup enabled          |
| Kubernetes       | kubelet, kubeadm, kubectl  | Latest stable, auto-detected   |
| CNI              | Calico v3.31.5             | Via Tigera operator            |
| Networking       | kube-proxy                 | iptables mode (default)        |

---

## Provisioning Sequence

The Vagrantfile provisions nodes sequentially in the order defined in `cluster.yaml`. Each node goes through three phases:

```mermaid
sequenceDiagram
    participant V as Vagrantfile
    participant CP as controlplane
    participant W1 as node01
    participant W2 as node02

    V->>CP: Phase 1 — OS Preparation (01-common.sh)
    V->>CP: Phase 2 — Kubernetes Install (02-kubernetes.sh)
    V->>CP: Phase 3 — kubeadm init + Calico (03-controlplane.sh)
    Note over CP: Writes join-command.sh to /vagrant

    V->>W1: Phase 1 — OS Preparation
    V->>W1: Phase 2 — Kubernetes Install
    V->>W1: Phase 3 — kubeadm join (04-worker.sh)
    Note over W1: Polls for join-command.sh

    V->>W2: Phase 1 — OS Preparation
    V->>W2: Phase 2 — Kubernetes Install
    V->>W2: Phase 3 — kubeadm join (04-worker.sh)
```

### Phase Details

| Phase | Script              | Runs On    | Purpose                                           |
|-------|---------------------|------------|---------------------------------------------------|
| 1     | `01-common.sh`      | All nodes  | Disable swap, load kernel modules, apply sysctl   |
| 2     | `02-kubernetes.sh`  | All nodes  | Install containerd, kubeadm, kubelet, kubectl     |
| 3     | `03-controlplane.sh`| CP only    | `kubeadm init`, deploy Calico, write join command |
| 3     | `04-worker.sh`      | Workers    | Poll for join command, execute `kubeadm join`     |

---

## File Coordination

The control plane and worker nodes coordinate through the Vagrant synced folder (`/vagrant`):

1. **Control plane** runs `kubeadm init` and generates a join token
2. The join command is saved to `/vagrant/join-command.sh` (visible to all VMs)
3. **Workers** poll for this file (up to 5 minutes) and execute it when found

This eliminates the need for SSH between VMs or external coordination services.

---

## Configuration Flow

```mermaid
flowchart LR
    A["cluster.yaml"] -->|parsed by| B["Vagrantfile (Ruby)"]
    B -->|defines VMs| C["VirtualBox VMs"]
    B -->|injects env vars| D["Provisioning Scripts"]
    D -->|run on| C
    C -->|forms| E["Kubernetes Cluster"]
```

All cluster decisions flow from `cluster.yaml` → `Vagrantfile` → provisioning scripts. No script editing is required for normal use.
