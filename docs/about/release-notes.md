---
title: Release Notes
description: Changelog and release history
---

# Release Notes

---

## v0.1.0 — Initial Release

**Release Date**: 2026-06-17

### Added

- Fully automated multi-node Kubernetes cluster provisioning via Vagrant and VirtualBox
- Single-file cluster topology configuration via `cluster.yaml`
- Calico CNI v3.31.5 support via Tigera operator
- Sequential provisioning: OS prep → Kubernetes install → cluster init / join
- Dynamic Kubernetes version detection (latest stable)
- Built-in test deployment script (`05-test.sh`)
- Progress bar output during provisioning
- VirtualBox host-only networking on `192.168.56.x`

### Known Limitations

- Provisioning scripts are **not idempotent** — re-provisioning a configured node may fail
- Kubernetes version is auto-detected at runtime; nodes provisioned at different times may get different versions
- `--ignore-preflight-errors=all` is used in `kubeadm init` — not suitable for production
- kubeadm join tokens expire after 24 hours; re-provisioning after a long halt may fail
- kubectl access requires SSH into the control plane VM (no host-side kubeconfig)
- Only VirtualBox/Vagrant provider is supported
- Only kubeadm distribution is supported
- Only Calico CNI is supported

### Infrastructure

- Guest OS: Ubuntu 22.04 LTS (`ubuntu/jammy64`)
- Container runtime: containerd
- CNI: Calico v3.31.5 via Tigera operator
- Networking: Pod CIDR `10.244.0.0/16`, Service CIDR `10.96.0.0/16`
