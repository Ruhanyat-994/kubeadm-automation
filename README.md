![Multinode Cluster Automation](./assets/Intro.png)

# Vagrant Kubernetes Cluster

A fully automated, **dynamically configurable** Kubernetes cluster running on VirtualBox via Vagrant. Add or remove nodes, adjust RAM and CPU, all from a single `cluster.yaml` file.

---

## How It Works

All cluster settings live in **`cluster.yaml`**. The `Vagrantfile` reads that file at runtime — no Ruby editing required. To change anything (node count, RAM, CPU, networking), edit `cluster.yaml` and run `vagrant up`.

```
vagrant-kubernetes-cluster/
├── cluster.yaml          ← Edit this to configure your cluster
├── Vagrantfile           ← Reads cluster.yaml automatically
└── scripts/
    ├── 01-common.sh      ← All nodes: swap, kernel, sysctl
    ├── 02-kubernetes.sh  ← All nodes: containerd + kubelet/kubeadm/kubectl
    ├── 03-controlplane.sh← Control plane: kubeadm init + Calico CNI
    ├── 04-worker.sh      ← Workers: join cluster
    └── 05-test.sh        ← Optional: deploy test httpd workload
```

---

## Default Cluster Layout

| VM             | Role          | IP            | RAM    | CPUs |
| -------------- | ------------- | ------------- | ------ | ---- |
| `controlplane` | Control Plane | 192.168.56.10 | 2 GB   | 2    |
| `node01`       | Worker        | 192.168.56.11 | 1.5 GB | 1    |
| `node02`       | Worker        | 192.168.56.12 | 1.5 GB | 1    |

**Kubernetes networking (configurable in cluster.yaml):**

* Pod CIDR: `10.244.0.0/16`
* Service CIDR: `10.96.0.0/16`
* CNI: Calico v3.31.5

---

## Prerequisites

* VirtualBox 6.1+
* Vagrant 2.3+
* At least **8 GB RAM** free and **4 CPU cores**
* Internet access


## Quick Start

```bash
# 1. Clone repo
cd vagrant-kubernetes-cluster

# 2. (Optional) Edit config
# cluster.yaml

# 3. Start cluster
vagrant up

# 4. SSH into control plane
vagrant ssh controlplane

# 5. Verify
kubectl get nodes
```

## Cluster Lifecycle Management (IMPORTANT)

### Suspend (Recommended – like hibernate)

```bash
vagrant suspend
```

* Saves full VM state (RAM + CPU)
* Fast resume
* Cluster remains exactly as-is

Resume:

```bash
vagrant up
```

Best for daily use

---

### Halt (Clean shutdown)

```bash
vagrant halt
```

* Gracefully shuts down VMs
* Slower restart than suspend

Start again:

```bash
vagrant up
```

---


### Control individual nodes

```bash
vagrant suspend node01
vagrant halt node02
vagrant up controlplane
```

Useful for:

* Testing node failures
* Simulating outages


##  After Resume / Restart

Sometimes nodes may show `NotReady` briefly:

```bash
kubectl get nodes
```

Wait 30–60 seconds — kubelet will recover automatically.

---

## Configuring Your Cluster (`cluster.yaml`)

### Change resources

```yaml
memory: 4096
cpus: 2
```

---

### Add nodes

```yaml
- name: "node03"
  ip: "192.168.56.13"
  memory: 2048
  cpus: 2
  role: "worker"
```

---

### Networking

```yaml
cluster:
  pod_cidr: "10.244.0.0/16"
  service_cidr: "10.96.0.0/16"
  calico_version: "v3.31.5"
```

---

## Testing the Cluster

```bash
vagrant ssh controlplane
sudo bash /vagrant/scripts/05-test.sh
```

---

## Useful Commands

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get pods -n kube-system
watch kubectl get tigerastatus
kubeadm token create --print-join-command
```

---

## Provisioning Order

1. controlplane → init + CNI
2. node01 → join
3. node02 → join
4. additional nodes → same

---

## Destroying the Cluster (Full Reset)

```bash
vagrant destroy -f
rm -f join-command.sh
```

### What this does:

* Deletes ALL VMs
* Removes cluster completely
* You must run `vagrant up` again (takes time)

Use only when:

* You want a fresh cluster
* Something is badly broken



## Recommended Workflow

| Use Case         | Command              |
| ---------------- | -------------------- |
| Daily stop/start | `vagrant suspend`    |
| Clean shutdown   | `vagrant halt`       |
| Full reset       | `vagrant destroy -f` |



## Troubleshooting

### Pods stuck in `ContainerCreating`

```bash
kubectl get tigerastatus
```
---

### `kubectl` connection refused

```bash
sudo systemctl restart containerd kubelet
```

### Worker `NotReady`

```bash
kubectl get pods -n calico-system -o wide
```


### Re-provision node

```bash
vagrant provision node01
```


## Script Reference

| Script               | Runs on | Purpose            |
| -------------------- | ------- | ------------------ |
| `01-common.sh`       | All     | System setup       |
| `02-kubernetes.sh`   | All     | Install Kubernetes |
| `03-controlplane.sh` | CP      | Init cluster       |
| `04-worker.sh`       | Workers | Join cluster       |
| `05-test.sh`         | CP      | Deploy test app    |

