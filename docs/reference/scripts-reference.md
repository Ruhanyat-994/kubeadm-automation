---
title: Scripts Reference
description: Detailed reference for each provisioning script
---

# Scripts Reference

KubeAuto uses five Bash scripts for cluster provisioning. All scripts use `set -euo pipefail` for strict error handling.

---

## Script Execution Order

| Order | Script               | Runs On        | Phase |
|-------|---------------------|----------------|-------|
| 1     | `01-common.sh`      | All nodes      | 1     |
| 2     | `02-kubernetes.sh`  | All nodes      | 2     |
| 3     | `03-controlplane.sh`| Control plane  | 3     |
| 3     | `04-worker.sh`      | Workers        | 3     |
| —     | `05-test.sh`        | Control plane  | Manual|

---

## 01-common.sh — OS Preparation

**Runs on**: All nodes (Phase 1)

**Purpose**: Prepares the operating system for Kubernetes installation.

**Actions**:

1. **Disables swap** permanently — `swapoff -a` and comments out the swap entry in `/etc/fstab`
2. **Updates APT** package index
3. **Installs prerequisite packages**: `apt-transport-https`, `ca-certificates`, `curl`, `gnupg`, `lsb-release`
4. **Loads kernel modules**: `overlay` and `br_netfilter` (persisted to `/etc/modules-load.d/k8s.conf`)
5. **Applies sysctl settings**: enables `bridge-nf-call-iptables`, `bridge-nf-call-ip6tables`, `net.ipv4.ip_forward` (persisted to `/etc/sysctl.d/k8s.conf`)
6. **Persists PRIMARY_IP** to `/etc/environment`

---

## 02-kubernetes.sh — Kubernetes Installation

**Runs on**: All nodes (Phase 2)

**Purpose**: Installs the container runtime and Kubernetes tooling.

**Actions**:

1. **Installs containerd** via APT
2. **Configures containerd** — generates default config and patches `SystemdCgroup = true`
3. **Detects Kubernetes version** — fetches the latest stable minor version from `https://dl.k8s.io/release/stable.txt`
4. **Adds Kubernetes APT repo** with GPG keyring for the detected version
5. **Installs** `kubelet`, `kubeadm`, `kubectl` and holds them at the installed version with `apt-mark hold`
6. **Configures crictl** to use the containerd socket
7. **Sets KUBELET_EXTRA_ARGS** in `/etc/default/kubelet` to bind kubelet to `PRIMARY_IP`
8. **Enables and reloads kubelet** via systemd

---

## 03-controlplane.sh — Cluster Initialisation

**Runs on**: Control plane only (Phase 3)

**Purpose**: Initialises the Kubernetes cluster and deploys the CNI.

**Actions**:

1. **Runs `kubeadm init`** with:
    - `--pod-network-cidr=$POD_CIDR`
    - `--service-cidr=$SERVICE_CIDR`
    - `--apiserver-advertise-address=$PRIMARY_IP`
2. **Sets up kubeconfig** for both `vagrant` user and `root`
3. **Installs Calico CRDs** from `calico/operator-crds.yaml`
4. **Deploys Tigera operator** from `calico/tigera-operator.yaml`
5. **Polls Tigera operator** for up to 3 minutes until the pod is `Running`
6. **Downloads and patches** `calico/custom-resources.yaml` (replaces default CIDR with `POD_CIDR`)
7. **Generates join command** and writes to `/vagrant/join-command.sh`
8. **Polls kube-system** until at least 6 pods are `Running`
9. **Prints summary** of nodes, pods, and Tigera status

---

## 04-worker.sh — Worker Join

**Runs on**: Worker nodes only (Phase 3)

**Purpose**: Joins the worker node to the existing cluster.

**Actions**:

1. **Polls for `/vagrant/join-command.sh`** — checks every 5 seconds for up to 5 minutes (60 attempts)
2. **Executes the join command** using `bash /vagrant/join-command.sh`
3. **Exits with error** if the join command is not found within the timeout

---

## 05-test.sh — Test Deployment

**Runs on**: Control plane only (manually)

**Purpose**: Validates the cluster by deploying a sample workload.

**Actions**:

1. **Deploys Apache httpd** (alpine) as a 2-replica Deployment
2. **Waits up to 2 minutes** for the Deployment to reach `Available`
3. **Exposes as NodePort** service on port 80
4. **Queries worker IPs** dynamically from the cluster
5. **Prints access URLs** for every worker node using the assigned NodePort

**Invocation**:

```bash
vagrant ssh controlplane
sudo bash /vagrant/scripts/05-test.sh
```
