---
title: Configuration Reference
description: Complete field-by-field reference for cluster.yaml
---

# Configuration Reference

This is the authoritative reference for every field in `cluster.yaml`.

---

## Cluster Section

```yaml
cluster:
  pod_cidr: "10.244.0.0/16"
  service_cidr: "10.96.0.0/16"
  calico_version: "v3.31.5"
  box: "ubuntu/jammy64"
```

| Field            | Type   | Required | Default          | Description                                            |
|-----------------|--------|----------|------------------|--------------------------------------------------------|
| `pod_cidr`      | string | Yes      | `10.244.0.0/16`  | CIDR range assigned to Kubernetes pods. Passed to `kubeadm init --pod-network-cidr` and used in the Calico custom resource. |
| `service_cidr`  | string | Yes      | `10.96.0.0/16`   | CIDR range assigned to Kubernetes services. Passed to `kubeadm init --service-cidr`. |
| `calico_version`| string | Yes      | `v3.31.5`        | Version tag of Calico to deploy. Used to construct the download URL for Calico operator and CRD manifests. |
| `box`           | string | Yes      | `ubuntu/jammy64` | Vagrant box name. All nodes use this image. Must be a valid box identifier on Vagrant Cloud. |

---

## Nodes Section

```yaml
nodes:
  - name: "controlplane"
    ip: "192.168.56.10"
    memory: 2048
    cpus: 2
    role: "controlplane"
```

| Field    | Type    | Required | Description                                                         |
|----------|---------|----------|---------------------------------------------------------------------|
| `name`   | string  | Yes      | VM hostname. Must be unique across all nodes. Used as the Vagrant machine name and Kubernetes node name. |
| `ip`     | string  | Yes      | IPv4 address on the VirtualBox host-only network (`192.168.56.x`). Must be unique. |
| `memory` | integer | Yes      | RAM allocation in megabytes. Control plane minimum: `2048`. Worker minimum: `1024`. |
| `cpus`   | integer | Yes      | Virtual CPU count. Control plane minimum: `2` (enforced by kubeadm). Workers: `1` or more. |
| `role`   | string  | Yes      | Node role. Must be `"controlplane"` or `"worker"`. Exactly one `controlplane` is required. |

---

## Validation Rules

The Vagrantfile performs the following validation at startup:

1. **Single control plane**: Exactly one node must have `role: "controlplane"`. Zero or multiple control plane nodes cause an immediate abort with a descriptive error.
2. **Field presence**: All five fields (`name`, `ip`, `memory`, `cpus`, `role`) must be present on every node.

---

## Derived Values

The Vagrantfile computes the following from `cluster.yaml`:

| Variable        | Source                                     | Used By               |
|----------------|--------------------------------------------|-----------------------|
| `CONTROL_PLANE_IP` | `ip` of the `controlplane` node         | All scripts           |
| `TOTAL_NODES`     | Length of the `nodes` array               | Progress bar display  |
| `WORKER_COUNT`    | Count of nodes with `role: "worker"`      | Progress bar display  |
| `POD_CIDR`        | `cluster.pod_cidr`                        | kubeadm init, Calico  |
| `SERVICE_CIDR`    | `cluster.service_cidr`                    | kubeadm init          |
| `CALICO_VERSION`  | `cluster.calico_version`                  | Calico manifest URLs  |
| `BOX_IMAGE`       | `cluster.box`                             | Vagrant VM definition |
