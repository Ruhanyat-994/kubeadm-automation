#!/usr/bin/env bash
# =============================================================================
# 02-kubernetes.sh – Run on ALL nodes
# Installs containerd (with systemd cgroup) and kubeadm/kubelet/kubectl
# =============================================================================
set -euo pipefail

# ── Progress helper ───────────────────────────────────────────────────────────
progress() {
  local pct="$1"; local msg="$2"
  local bar_len=40
  local filled=$(( pct * bar_len / 100 ))
  local empty=$(( bar_len - filled ))
  local bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done
  printf "\r  [%s] %3d%%  %s\n" "${bar}" "${pct}" "${msg}"
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🐳  [${NODE_NAME}] Phase 2/3 — Kubernetes Runtime & Packages"
echo "      Node ${NODE_INDEX}/${TOTAL_NODES}  |  IP: ${PRIMARY_IP}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Install containerd ─────────────────────────────────────────────────────
progress 5 "Installing containerd..."
apt-get install -y -qq containerd
progress 20 "containerd installed ✓"

# ── 2. Configure containerd systemd cgroup ────────────────────────────────────
progress 25 "Configuring containerd (SystemdCgroup = true)..."
mkdir -p /etc/containerd
containerd config default \
  | sed 's/SystemdCgroup = false/SystemdCgroup = true/' \
  | tee /etc/containerd/config.toml > /dev/null
systemctl restart containerd
systemctl enable containerd --quiet
progress 40 "containerd configured ✓"

# ── 3. Detect latest stable Kubernetes version ────────────────────────────────
progress 45 "Detecting latest stable Kubernetes version..."
KUBE_LATEST=$(curl -sSL https://dl.k8s.io/release/stable.txt \
              | awk 'BEGIN{FS="."}{printf "%s.%s",$1,$2}')
echo "      → Using Kubernetes repo: ${KUBE_LATEST}"
progress 50 "Version detected: ${KUBE_LATEST} ✓"

# ── 4. Add Kubernetes apt repository ─────────────────────────────────────────
progress 55 "Adding Kubernetes APT repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/Release.key" \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/${KUBE_LATEST}/deb/ /" \
  | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
apt-get update -qq
progress 65 "Repository added ✓"

# ── 5. Install kubelet, kubeadm, kubectl ─────────────────────────────────────
progress 70 "Installing kubelet, kubeadm, kubectl..."
apt-get install -y -qq kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
progress 85 "Kubernetes packages installed ✓"

# ── 6. Configure crictl ───────────────────────────────────────────────────────
progress 88 "Configuring crictl (container runtime interface)..."
crictl config \
  --set runtime-endpoint=unix:///run/containerd/containerd.sock \
  --set image-endpoint=unix:///run/containerd/containerd.sock
progress 93 "crictl configured ✓"

# ── 7. Set kubelet node IP ────────────────────────────────────────────────────
progress 96 "Setting kubelet node IP to ${PRIMARY_IP}..."
cat <<EOF | tee /etc/default/kubelet > /dev/null
KUBELET_EXTRA_ARGS='--node-ip ${PRIMARY_IP}'
EOF
systemctl daemon-reload
systemctl enable kubelet --quiet

progress 100 "Phase 2/3 complete ✓"
echo ""