---
title: Advanced Options
description: Advanced cluster configuration and customisation techniques
---

# Advanced Options

This guide covers advanced configuration and customisation scenarios beyond the defaults.

---

## Adjusting Node Resources

### Increase Worker RAM

For resource-intensive workloads, increase worker memory in `cluster.yaml`:

```yaml
- name: "node01"
  ip: "192.168.56.11"
  memory: 4096          # 4 GB instead of default 1.5 GB
  cpus: 2               # 2 CPUs instead of default 1
  role: "worker"
```

After changing resources, destroy and recreate the affected node:

```bash
vagrant destroy node01 -f
vagrant up node01
```

!!! warning
    `vagrant reload` does not apply memory/CPU changes. You must destroy and recreate the VM.

---

## Changing Network Configuration

### Custom Pod CIDR

The default pod CIDR is `10.244.0.0/16`. To use a different range:

```yaml
cluster:
  pod_cidr: "172.16.0.0/16"
```

!!! danger "Full Cluster Rebuild Required"
    Changing the pod CIDR requires destroying all VMs and re-provisioning from scratch, since it is baked into `kubeadm init` and the Calico configuration.

### Custom Service CIDR

```yaml
cluster:
  service_cidr: "10.100.0.0/16"
```

The same full-rebuild requirement applies.

---

## Scaling the Cluster

### Adding Worker Nodes to a Running Cluster

1. Add a new node entry to `cluster.yaml`:

    ```yaml
    - name: "node04"
      ip: "192.168.56.14"
      memory: 2048
      cpus: 2
      role: "worker"
    ```

2. Bring up only the new node:

    ```bash
    vagrant up node04
    ```

    The new worker will automatically find and execute the join command from the shared `/vagrant` folder.

!!! info "Join Token Expiry"
    kubeadm join tokens expire after 24 hours. If the cluster was created more than 24 hours ago, generate a new token first:
    ```bash
    vagrant ssh controlplane
    sudo kubeadm token create --print-join-command > /vagrant/join-command.sh
    ```

### Removing a Worker Node

1. Drain the node from the control plane:

    ```bash
    vagrant ssh controlplane
    kubectl drain node03 --ignore-daemonsets --delete-emptydir-data
    kubectl delete node node03
    ```

2. Destroy the VM:

    ```bash
    vagrant destroy node03 -f
    ```

3. Remove or comment out the node entry in `cluster.yaml`.

---

## Changing the Calico CNI Version

To use a different Calico version:

```yaml
cluster:
  calico_version: "v3.28.0"
```

!!! note
    This requires a full cluster rebuild. The Calico manifests are downloaded from the official release URL based on this version string.

---

## Using a Different Vagrant Box

To use a different base OS image:

```yaml
cluster:
  box: "ubuntu/focal64"    # Ubuntu 20.04 LTS
```

!!! warning "Compatibility"
    The provisioning scripts are tested with `ubuntu/jammy64` (22.04 LTS). Other Ubuntu versions may work but are not officially tested. Non-Ubuntu distributions are not supported in v0.1.0.

---

## Useful kubectl Commands

```bash
# Detailed node information
kubectl describe node controlplane

# Resource usage (requires metrics-server, not included in v0.1.0)
kubectl top nodes
kubectl top pods -A

# Watch events in real time
kubectl get events --watch

# Get cluster information
kubectl cluster-info

# View kubeadm cluster configuration
kubectl -n kube-system get cm kubeadm-config -o yaml
```
