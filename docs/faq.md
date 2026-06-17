---
title: FAQ
description: Frequently asked questions about KubeAuto
---

# Frequently Asked Questions

---

## General

### What is KubeAuto?

KubeAuto is an open-source automation tool that provisions multi-node Kubernetes clusters on your local machine using Vagrant, VirtualBox, and kubeadm. You configure everything in a single YAML file and run one command.

### What is KubeAuto good for?

- Learning Kubernetes in a realistic multi-node environment
- Testing applications locally before deploying to production
- Developing and debugging Kubernetes configurations
- Simulating node failures and recovery scenarios

### Is KubeAuto production-ready?

No. KubeAuto v0.1.0 is designed for **local development and learning**. It uses `--ignore-preflight-errors=all` and does not implement production-grade security. See the [Release Notes](about/release-notes.md) for known limitations.

---

## Setup

### How much RAM do I need?

At minimum, **8 GB free RAM** for the default 3-node cluster. See [System Requirements](getting-started/system-requirements.md) for detailed specs.

### Does it work on Apple Silicon (M1/M2/M3)?

VirtualBox 7.0+ has experimental support for Apple Silicon. It may work but is not officially tested. Consider using UTM or Docker-based alternatives for ARM Macs.

### Can I run it on Linux without a GUI?

Yes. VirtualBox runs headlessly — no desktop environment or GUI is required.

### Does it work with Hyper-V enabled?

No. VirtualBox and Hyper-V cannot run simultaneously on Windows. Disable Hyper-V:
```powershell
bcdedit /set hypervisorlaunchtype off
```
Then restart your computer.

---

## Usage

### How do I add more worker nodes?

Add a new entry to the `nodes` section in `cluster.yaml` and run `vagrant up`. See [Adding Worker Nodes](usage/advanced-options.md#adding-worker-nodes-to-a-running-cluster).

### Can I change resources after provisioning?

You must destroy and recreate the affected VM:
```bash
vagrant destroy node01 -f
vagrant up node01
```

### How do I access the cluster from my host machine?

In v0.1.0, kubectl must be run from inside the control plane VM via `vagrant ssh controlplane`. Host-side kubectl access is planned for a future release.

### Why is the first `vagrant up` so slow?

The first run downloads the Ubuntu Vagrant box (~600 MB), all Kubernetes packages, and Calico manifests. Subsequent runs reuse cached data and are much faster.

---

## Troubleshooting

### Nodes show NotReady after restart — is this normal?

Yes. After `vagrant up` following `vagrant halt`, nodes may show `NotReady` for 30–60 seconds while kubelet reconnects. Wait and re-check with `kubectl get nodes`.

### How do I completely reset everything?

```bash
vagrant destroy -f
rm -f join-command.sh
vagrant up
```

### Where can I get help?

- [Troubleshooting Guide](operations/troubleshooting.md)
- [GitHub Issues](https://github.com/Ruhanyat-994/kubeadm-automation/issues)
