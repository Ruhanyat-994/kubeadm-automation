---
title: Installation Guide
description: Detailed installation and first cluster setup walkthrough
---

# Installation Guide

This guide walks you through the complete installation process from start to finish.

---

## 1. Install Prerequisites

Follow the platform-specific instructions in the [Prerequisites](../getting-started/prerequisites.md) guide to install:

- [x] VirtualBox 6.1+
- [x] Vagrant 2.3+
- [x] Git

---

## 2. Clone the Repository

```bash
git clone https://github.com/Ruhanyat-994/kubeadm-automation.git
cd kubeadm-automation
```

---

## 3. Understand the Project Structure

```
kubeadm-automation/
├── cluster.yaml          ← Cluster configuration (edit this)
├── Vagrantfile           ← VM orchestration (do not edit)
├── scripts/
│   ├── 01-common.sh      ← OS preparation (all nodes)
│   ├── 02-kubernetes.sh  ← Kubernetes install (all nodes)
│   ├── 03-controlplane.sh← Cluster init (control plane)
│   ├── 04-worker.sh      ← Cluster join (workers)
│   └── 05-test.sh        ← Test deployment (optional)
├── assets/
│   └── Intro.png
└── README.md
```

!!! tip "Key Principle"
    You only need to edit `cluster.yaml`. The Vagrantfile reads it automatically — no Ruby knowledge required.

---

## 4. Configure Your Cluster

Open `cluster.yaml` in your preferred editor:

```bash
nano cluster.yaml     # Linux / macOS
notepad cluster.yaml  # Windows
code cluster.yaml     # VS Code
```

The default configuration creates a 3-node cluster (1 control plane + 2 workers). See the [Configuration](configuration.md) guide for all available options.

---

## 5. Provision the Cluster

Start all VMs and run the provisioning scripts:

```bash
vagrant up
```

### What Happens During Provisioning

| Step | Duration   | Description                                                |
|------|------------|-----------------------------------------------------------|
| 1    | ~2 min     | Download Ubuntu box image (first time only)                |
| 2    | ~3 min     | Create VMs in VirtualBox                                   |
| 3    | ~3 min     | OS preparation: disable swap, kernel modules, sysctl       |
| 4    | ~4 min     | Install containerd, kubeadm, kubelet, kubectl              |
| 5    | ~3 min     | kubeadm init on control plane, deploy Calico CNI           |
| 6    | ~2 min     | Worker nodes join the cluster                              |

!!! info "Progress Bars"
    Each script prints a progress bar to your terminal so you can track the provisioning status in real time.

---

## 6. Verify the Installation

```bash
# SSH into the control plane
vagrant ssh controlplane

# Check nodes
kubectl get nodes

# Check system pods
kubectl get pods -n kube-system

# Check Calico status
kubectl get tigerastatus
```

All nodes should show `Ready` and all system pods should show `Running`.

---

## 7. Test with a Sample Workload

Deploy the included test workload:

```bash
sudo bash /vagrant/scripts/05-test.sh
```

This creates an Apache HTTP server deployment with 2 replicas and exposes it via a NodePort service. The script prints the URLs you can open in your host browser.

---

## Uninstalling

To completely remove the cluster and all VMs:

```bash
vagrant destroy -f
rm -f join-command.sh
```

This deletes all VM data. You can re-create the cluster at any time by running `vagrant up` again.
