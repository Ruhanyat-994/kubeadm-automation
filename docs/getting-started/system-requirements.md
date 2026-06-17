---
title: System Requirements
description: Detailed hardware, OS, and software compatibility requirements
---

# System Requirements

This page provides detailed system requirements for running KubeAuto clusters.

---

## Supported Host Operating Systems

| Operating System        | Status          | Notes                                      |
|------------------------|-----------------|---------------------------------------------|
| Windows 10/11 (x64)   | ✅ Supported    | Hyper-V must be disabled for VirtualBox     |
| macOS 12+ (Intel)      | ✅ Supported    | Full support                                |
| macOS 13+ (Apple Silicon) | ⚠️ Limited  | Requires VirtualBox 7.0+ beta for ARM      |
| Ubuntu 22.04+ (x64)   | ✅ Supported    | Full support                                |
| Fedora 38+ (x64)      | ✅ Supported    | Full support                                |
| Other Linux (x64)     | ⚠️ Likely works | VirtualBox and Vagrant must be available    |

---

## Hardware Requirements by Cluster Size

### Minimal Cluster (1 control plane + 1 worker)

| Resource | Host Requirement |
|----------|-----------------|
| RAM      | 6 GB free       |
| CPU      | 4 cores         |
| Disk     | 20 GB free      |

### Default Cluster (1 control plane + 3 workers)

| Resource | Host Requirement |
|----------|-----------------|
| RAM      | 10 GB free      |
| CPU      | 6 cores         |
| Disk     | 40 GB free      |

### Large Cluster (1 control plane + 5+ workers)

| Resource | Host Requirement |
|----------|-----------------|
| RAM      | 16 GB+ free     |
| CPU      | 8+ cores        |
| Disk     | 60 GB+ free     |

---

## Per-Node Resource Defaults

These are the defaults configured in `cluster.yaml`:

| Node Type       | RAM       | CPUs | Disk (dynamic) |
|----------------|-----------|------|----------------|
| Control Plane  | 2048 MB   | 2    | ~10 GB         |
| Worker Node    | 1536 MB   | 1    | ~8 GB          |

!!! tip "Adjusting Resources"
    All values are configurable in `cluster.yaml`. See the [Configuration](../installation/configuration.md) guide for details.

---

## Guest VM Operating System

All VMs run **Ubuntu 22.04 LTS (Jammy Jellyfish)** 64-bit, using the `ubuntu/jammy64` Vagrant box. This is downloaded automatically on first run.

---

## Software Version Compatibility

| Software      | Minimum Version | Tested Version |
|--------------|-----------------|----------------|
| VirtualBox   | 6.1             | 7.0.x          |
| Vagrant      | 2.3             | 2.4.x          |
| Kubernetes   | Auto-detected   | Latest stable   |
| Calico CNI   | v3.31.5         | v3.31.5        |
| containerd   | Latest in APT   | Latest          |

---

## Network Configuration

The cluster uses a VirtualBox **host-only network** on the `192.168.56.x` subnet:

| Component       | IP / Range        |
|----------------|-------------------|
| Control Plane  | `192.168.56.10`   |
| Worker Nodes   | `192.168.56.11+`  |
| Pod CIDR       | `10.244.0.0/16`   |
| Service CIDR   | `10.96.0.0/16`    |

!!! warning "IP Conflicts"
    Ensure no other VirtualBox VMs or services use the `192.168.56.x` range.
