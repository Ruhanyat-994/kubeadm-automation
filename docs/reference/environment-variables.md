---
title: Environment Variables
description: Environment variables injected into provisioning scripts
---

# Environment Variables

The Vagrantfile injects these environment variables into each provisioning script. They are derived from `cluster.yaml` and computed at runtime.

---

## Variables Available in All Scripts

| Variable        | Source                      | Example Value        | Description                              |
|----------------|-----------------------------|--------------------|------------------------------------------|
| `PRIMARY_IP`   | Current node's `ip` field   | `192.168.56.10`    | The private network IP of the current node |
| `NODE_NAME`    | Current node's `name` field | `controlplane`     | Hostname of the current node             |
| `NODE_INDEX`   | Position in `nodes` array   | `0`                | Zero-based index of the current node     |
| `TOTAL_NODES`  | Length of `nodes` array     | `4`                | Total number of nodes in the cluster     |
| `WORKER_COUNT` | Count of worker nodes       | `3`                | Number of worker nodes                   |
| `PHASE`        | Current provisioning phase  | `1`                | Current script phase number (1, 2, or 3) |
| `PHASE_TOTAL`  | Total phases                | `3`                | Always `3`                               |

---

## Variables Available in Phase 2+ Scripts

| Variable        | Source                        | Example Value     | Description                              |
|----------------|-------------------------------|-------------------|------------------------------------------|
| `POD_CIDR`     | `cluster.pod_cidr`            | `10.244.0.0/16`   | Pod network CIDR range                   |
| `SERVICE_CIDR` | `cluster.service_cidr`        | `10.96.0.0/16`    | Service network CIDR range               |
| `CALICO_VERSION`| `cluster.calico_version`     | `v3.31.5`         | Calico CNI version to deploy             |

---

## Control Plane–Only Variable

| Variable           | Source                     | Example Value     | Description                           |
|-------------------|----------------------------|-------------------|---------------------------------------|
| `CONTROL_PLANE_IP`| `ip` of the controlplane node| `192.168.56.10` | Used as `--apiserver-advertise-address`|

---

## How Variables Are Injected

The Vagrantfile uses Vagrant's `shell` provisioner with inline `env` parameter:

```ruby
node_config.vm.provision "shell",
  path: "scripts/01-common.sh",
  env: {
    "PRIMARY_IP"   => node["ip"],
    "NODE_NAME"    => node["name"],
    "NODE_INDEX"   => index.to_s,
    "TOTAL_NODES"  => nodes.length.to_s,
    "WORKER_COUNT" => worker_count.to_s,
    "PHASE"        => "1",
    "PHASE_TOTAL"  => "3"
  }
```

Scripts access these as standard environment variables:

```bash
echo "Running on node: $NODE_NAME at IP: $PRIMARY_IP"
```

---

## System Files Written by Scripts

Several scripts write values to persistent system files:

| File                          | Written By         | Content                         |
|------------------------------|--------------------|---------------------------------|
| `/etc/environment`           | `01-common.sh`     | `PRIMARY_IP=<ip>`              |
| `/etc/modules-load.d/k8s.conf`| `01-common.sh`   | `overlay` and `br_netfilter`   |
| `/etc/sysctl.d/k8s.conf`    | `01-common.sh`     | Bridge and IP forwarding rules |
| `/etc/default/kubelet`       | `02-kubernetes.sh` | `KUBELET_EXTRA_ARGS=--node-ip=<ip>` |
| `/vagrant/join-command.sh`   | `03-controlplane.sh`| kubeadm join command           |
