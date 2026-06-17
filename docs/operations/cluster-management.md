---
title: Cluster Management
description: Lifecycle management, maintenance, and reset procedures
---

# Cluster Management

This guide covers the full lifecycle management of a KubeAuto cluster.

---

## Lifecycle Commands

| Operation          | Command                   | When to Use                     |
|-------------------|---------------------------|---------------------------------|
| Start / Resume    | `vagrant up`              | Begin a session                 |
| Suspend           | `vagrant suspend`         | Pause for the day               |
| Halt              | `vagrant halt`            | Clean shutdown before reboot    |
| Destroy           | `vagrant destroy -f`      | Full reset, delete everything   |
| Re-provision      | `vagrant provision <node>`| Re-run setup scripts on a node  |

---

## Recommended Workflow

### Daily Development

```bash
# Morning — resume
vagrant up

# Work with your cluster...
vagrant ssh controlplane
kubectl get nodes

# Evening — save state
vagrant suspend
```

### Before Host Reboot

```bash
vagrant halt
# Reboot your machine
vagrant up
```

### Complete Reset

```bash
vagrant destroy -f
rm -f join-command.sh
vagrant up
```

---

## Re-provisioning Nodes

If a node's provisioning failed or you want to re-run the setup scripts:

```bash
vagrant provision controlplane
vagrant provision node01
```

!!! warning "Not Idempotent (v0.1.0)"
    The current provisioning scripts are **not fully idempotent**. Re-provisioning a fully configured node may fail because `kubeadm init` detects an existing cluster. For a clean re-setup, destroy and recreate the node instead:
    ```bash
    vagrant destroy node01 -f
    vagrant up node01
    ```

---

## Monitoring Cluster Health

### Quick Health Check

```bash
vagrant ssh controlplane

# All nodes Ready?
kubectl get nodes

# All system pods Running?
kubectl get pods -n kube-system

# Calico healthy?
kubectl get tigerastatus
```

### Detailed Diagnostics

```bash
# Node conditions and events
kubectl describe node controlplane

# Recent cluster events
kubectl get events --sort-by=.metadata.creationTimestamp

# kubelet logs on a node
sudo journalctl -u kubelet --no-pager -n 50
```

---

## Recovering from Common Issues

### Nodes Show NotReady After Resume

Wait 30–60 seconds. If a node doesn't recover:

```bash
# From inside the affected node
vagrant ssh node01
sudo systemctl restart containerd kubelet
```

### Recreating a Single Worker

```bash
# From host
vagrant destroy node02 -f
vagrant up node02
```

### Full Cluster Reset

```bash
vagrant destroy -f
rm -f join-command.sh
vagrant up
```

This is the nuclear option — only use when the cluster is unrecoverable.

---

## Useful Maintenance Commands

```bash
# Check Vagrant VM status
vagrant status

# List all VirtualBox VMs
VBoxManage list vms

# Check disk usage of VMs
VBoxManage list hdds

# Generate a new join token (if expired)
vagrant ssh controlplane
sudo kubeadm token create --print-join-command > /vagrant/join-command.sh
```
