#!/usr/bin/env bash
# =============================================================================
# 01-common.sh – Run on ALL nodes
# Disables swap, configures kernel modules and sysctl settings
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
echo "  📦  [${NODE_NAME}] Phase 1/3 — System Setup"
echo "      Node ${NODE_INDEX}/${TOTAL_NODES}  |  IP: ${PRIMARY_IP}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Disable swap ───────────────────────────────────────────────────────────
progress 5 "Disabling swap..."
swapoff -a
sed -i '/\sswap\s/s/^/#/' /etc/fstab
progress 15 "Swap disabled ✓"

# ── 2. Update packages ────────────────────────────────────────────────────────
progress 20 "Updating package index..."
apt-get update -qq
progress 35 "Installing prerequisites..."
apt-get install -y -qq apt-transport-https ca-certificates curl gnupg lsb-release
progress 50 "Prerequisites installed ✓"

# ── 3. Kernel modules ─────────────────────────────────────────────────────────
progress 55 "Loading kernel modules (overlay, br_netfilter)..."
cat <<EOF | tee /etc/modules-load.d/k8s.conf > /dev/null
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter
progress 70 "Kernel modules loaded ✓"

# ── 4. Sysctl settings ────────────────────────────────────────────────────────
progress 75 "Applying sysctl networking settings..."
cat <<EOF | tee /etc/sysctl.d/k8s.conf > /dev/null
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system > /dev/null 2>&1
progress 90 "Sysctl applied ✓"

# ── 5. Persist PRIMARY_IP ─────────────────────────────────────────────────────
progress 95 "Persisting node environment variables..."
grep -q "^PRIMARY_IP=" /etc/environment && \
  sed -i "s/^PRIMARY_IP=.*/PRIMARY_IP=${PRIMARY_IP}/" /etc/environment || \
  echo "PRIMARY_IP=${PRIMARY_IP}" >> /etc/environment

progress 100 "Phase 1/3 complete ✓"
echo ""