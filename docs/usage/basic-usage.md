---
title: Basic Usage
description: Day-to-day cluster management commands
---

# Basic Usage

This guide covers the essential commands for managing your KubeAuto cluster on a daily basis.

---

## Starting the Cluster

```bash
vagrant up
```

If the cluster was previously suspended, this resumes all VMs instantly. If VMs were halted, this performs a cold boot.

---

## Stopping the Cluster

### Suspend (Recommended for Daily Use)

```bash
vagrant suspend
```

- Saves the full VM state (RAM + CPU) to disk
- **Fast resume** — typically under 10 seconds
- Cluster remains exactly as you left it
- Uses additional disk space for the saved state

### Halt (Clean Shutdown)

```bash
vagrant halt
```

- Gracefully shuts down all VMs
- Slower restart compared to suspend
- No additional disk usage

!!! tip "When to Use Which"
    Use `vagrant suspend` for daily work. Use `vagrant halt` before a system reboot or when you won't use the cluster for an extended period.

---

## Accessing Nodes

### SSH into the Control Plane

```bash
vagrant ssh controlplane
```

### SSH into a Specific Worker

```bash
vagrant ssh node01
vagrant ssh node02
```

### Exit SSH

```bash
exit
```

---

## Using kubectl

After SSH-ing into the control plane, kubectl is available immediately:

```bash
# List all nodes
kubectl get nodes

# Show detailed node info
kubectl get nodes -o wide

# List all pods across all namespaces
kubectl get pods -A

# List system pods
kubectl get pods -n kube-system

# Watch Calico networking status
kubectl get tigerastatus
```

---

## Managing Individual Nodes

You can target specific nodes with any Vagrant command:

```bash
# Suspend a specific node
vagrant suspend node01

# Halt a specific node
vagrant halt node02

# Resume a specific node
vagrant up node01

# Re-provision a node (re-runs setup scripts)
vagrant provision node01
```

!!! info "Use Case"
    Individually managing nodes is useful for testing Kubernetes behaviour during node failures, simulating maintenance windows, or debugging provisioning issues.

---

## Checking Cluster Status

After resuming or restarting the cluster:

```bash
vagrant ssh controlplane
kubectl get nodes
```

!!! note "Brief NotReady Period"
    After a `vagrant up` following `vagrant halt`, nodes may show `NotReady` for 30–60 seconds while kubelet and the CNI re-establish connections. This is normal — wait and re-check.

---

## Deploying the Test Workload

KubeAuto includes a built-in test script:

```bash
vagrant ssh controlplane
sudo bash /vagrant/scripts/05-test.sh
```

This deploys:

- An Apache httpd deployment with 2 replicas
- A NodePort service exposing port 80

The script prints the URLs you can access from your host browser.

---

## Quick Reference

| Operation              | Command                         |
|------------------------|----------------------------------|
| Start / resume cluster | `vagrant up`                    |
| Suspend cluster        | `vagrant suspend`               |
| Halt cluster           | `vagrant halt`                  |
| Destroy cluster        | `vagrant destroy -f`            |
| SSH into control plane | `vagrant ssh controlplane`      |
| SSH into worker        | `vagrant ssh <node_name>`       |
| Re-provision a node    | `vagrant provision <node_name>` |
| Check node status      | `kubectl get nodes`             |
