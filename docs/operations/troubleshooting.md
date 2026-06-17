---
title: Troubleshooting
description: Common issues and their solutions
---

# Troubleshooting

This page documents common issues you may encounter and their solutions.

---

## Provisioning Issues

### `vagrant up` hangs or times out

**Symptoms**: The terminal appears stuck during provisioning with no progress.

**Solutions**:

1. Check your internet connection — packages are downloaded during first provisioning
2. Ensure VirtualBox is not blocked by your firewall
3. Ensure Hyper-V is disabled (Windows): `bcdedit /set hypervisorlaunchtype off`
4. Try destroying and recreating: `vagrant destroy -f && vagrant up`

---

### `kubeadm init` fails with preflight errors

**Symptoms**: Provisioning fails during Phase 3 on the control plane.

**Solutions**:

1. Ensure the control plane has at least 2 CPUs in `cluster.yaml`
2. Ensure at least 2 GB RAM is allocated to the control plane
3. Check that no other Kubernetes installation exists on the VM

---

### Worker nodes fail to join

**Symptoms**: Workers time out waiting for `join-command.sh`.

**Solutions**:

1. Verify the control plane provisioned successfully first
2. Check that `/vagrant` synced folder is working: `vagrant ssh node01 -c "ls /vagrant/"`
3. If the join token expired (cluster older than 24 hours), regenerate it:

```bash
vagrant ssh controlplane
sudo kubeadm token create --print-join-command > /vagrant/join-command.sh
exit
vagrant provision node01
```

---

## Runtime Issues

### Nodes show `NotReady` after resume

**Symptoms**: After `vagrant up` (resuming from halt), nodes show `NotReady`.

**Solution**: Wait 30–60 seconds for kubelet and Calico to re-establish connections. If a node doesn't recover:

```bash
vagrant ssh <node_name>
sudo systemctl restart containerd kubelet
```

---

### Pods stuck in `ContainerCreating`

**Symptoms**: Pods don't start, staying in `ContainerCreating` state.

**Solutions**:

1. Check Calico status:
    ```bash
    kubectl get tigerastatus
    kubectl get pods -n calico-system
    ```
2. If Calico pods are not running, check the Tigera operator:
    ```bash
    kubectl get pods -n tigera-operator
    ```
3. Restart Calico on the affected node:
    ```bash
    vagrant ssh <node_name>
    sudo systemctl restart containerd
    ```

---

### `kubectl` connection refused

**Symptoms**: `kubectl` commands fail with "connection refused" on the control plane.

**Solutions**:

1. Restart the API server and kubelet:
    ```bash
    sudo systemctl restart kubelet
    ```
2. Verify the API server is running:
    ```bash
    sudo crictl ps | grep kube-apiserver
    ```
3. Check kubeconfig:
    ```bash
    echo $KUBECONFIG
    ls -la ~/.kube/config
    ```

---

### DNS resolution failures inside pods

**Symptoms**: Pods cannot resolve hostnames (e.g., `nslookup kubernetes.default` fails).

**Solutions**:

1. Check CoreDNS pods:
    ```bash
    kubectl get pods -n kube-system -l k8s-app=kube-dns
    ```
2. Restart CoreDNS:
    ```bash
    kubectl rollout restart deployment coredns -n kube-system
    ```

---

## VirtualBox Issues

### VirtualBox kernel driver not installed

**Symptoms**: `vagrant up` fails with VirtualBox driver errors.

**Solutions**:

=== "Linux"
    ```bash
    sudo /sbin/vboxconfig
    ```
    Or reinstall VirtualBox.

=== "Windows"
    Ensure Hyper-V is disabled:
    ```powershell
    bcdedit /set hypervisorlaunchtype off
    ```
    Restart your computer.

---

### IP address conflict

**Symptoms**: VMs fail to start or cannot communicate.

**Solutions**:

1. Check for conflicting VirtualBox host-only networks:
    ```bash
    VBoxManage list hostonlyifs
    ```
2. Ensure no other VMs use the `192.168.56.x` range
3. Remove stale host-only networks from VirtualBox preferences

---

## Getting More Help

### Collect Diagnostic Information

If you need to report an issue, collect:

```bash
# Vagrant status
vagrant status

# VirtualBox version
VBoxManage --version

# Vagrant version
vagrant --version

# Node status (from control plane)
kubectl get nodes -o wide
kubectl get pods -A
kubectl get events --sort-by=.metadata.creationTimestamp
```

### Report an Issue

Open an issue at [github.com/Ruhanyat-994/kubeadm-automation/issues](https://github.com/Ruhanyat-994/kubeadm-automation/issues) with:

1. Your host OS and version
2. VirtualBox and Vagrant versions
3. The error message or unexpected behaviour
4. Your `cluster.yaml` content (with any sensitive data removed)
5. Diagnostic output from the commands above
