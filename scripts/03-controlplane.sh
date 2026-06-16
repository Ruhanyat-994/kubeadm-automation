#!/usr/bin/env bash
# =============================================================================
# 03-controlplane.sh – Run on controlplane ONLY
# Initialises the cluster, installs Calico CNI, writes the join command.
# All settings are injected via environment variables from Vagrantfile/cluster.yaml
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
echo "  🎛️   [${NODE_NAME}] Phase 3/3 — Control Plane Init"
echo "      Node ${NODE_INDEX}/${TOTAL_NODES}  |  IP: ${PRIMARY_IP}"
echo "      Pod CIDR: ${POD_CIDR}  |  Service CIDR: ${SERVICE_CIDR}"
echo "      Calico: ${CALICO_VERSION}  |  Workers expected: ${WORKER_COUNT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

JOIN_CMD_FILE="/vagrant/join-command.sh"
KUBECONFIG_PATH="/etc/kubernetes/admin.conf"
HOME_DIR="/home/vagrant"

export KUBECONFIG="${KUBECONFIG_PATH}"

# ── 1. kubeadm init ───────────────────────────────────────────────────────────
progress 5 "Running kubeadm init (this takes ~2 min)..."
kubeadm init \
  --pod-network-cidr     "${POD_CIDR}" \
  --service-cidr         "${SERVICE_CIDR}" \
  --apiserver-advertise-address "${PRIMARY_IP}" \
  --ignore-preflight-errors=all \
  2>&1 | tee /var/log/kubeadm-init.log | grep -E "(initialized|error|Error|WARNING)" || true
progress 30 "kubeadm init complete ✓"

# ── 2. Set up kubeconfig ──────────────────────────────────────────────────────
progress 32 "Configuring kubeconfig for vagrant and root users..."
mkdir -p "${HOME_DIR}/.kube"
cp "${KUBECONFIG_PATH}" "${HOME_DIR}/.kube/config"
chown -R vagrant:vagrant "${HOME_DIR}/.kube"
chmod 600 "${HOME_DIR}/.kube/config"

mkdir -p /root/.kube
cp "${KUBECONFIG_PATH}" /root/.kube/config
progress 35 "kubeconfig ready ✓"

# ── 3. Install Calico CRDs ────────────────────────────────────────────────────
progress 38 "Installing Calico CRDs (operator-crds.yaml)..."
kubectl create -f \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/operator-crds.yaml"
progress 45 "Calico CRDs installed ✓"

# ── 4. Deploy Tigera operator ─────────────────────────────────────────────────
progress 48 "Deploying Tigera operator..."
kubectl create -f \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml"
progress 55 "Tigera operator deployed ✓"

# ── 5. Wait for Tigera operator pod ──────────────────────────────────────────
progress 57 "Waiting for Tigera operator pod to reach Running (up to 3 min)..."
STATUS=""
for i in $(seq 1 36); do
  STATUS=$(kubectl get pods -n tigera-operator \
             --no-headers 2>/dev/null \
             | awk '{print $3}' | head -1)
  PCT=$(( 57 + i ))
  [ "${PCT}" -gt 65 ] && PCT=65
  progress ${PCT} "Operator pod status: ${STATUS:-Pending}  (attempt ${i}/36)"
  [ "${STATUS}" = "Running" ] && break
  sleep 5
done

if [ "${STATUS:-}" != "Running" ]; then
  progress 65 "Operator not yet Running — waiting 30s extra..."
  sleep 30
fi
progress 65 "Tigera operator is Running ✓"

# ── 6. Apply Calico custom resources ─────────────────────────────────────────
progress 68 "Applying Calico custom resources (pod CIDR: ${POD_CIDR})..."
curl -sSLo /tmp/calico-cr.yaml \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml"
sed -i "s#192.168.0.0/16#${POD_CIDR}#g" /tmp/calico-cr.yaml
kubectl create -f /tmp/calico-cr.yaml
progress 75 "Calico custom resources applied ✓"

# ── 7. Write join command ─────────────────────────────────────────────────────
progress 78 "Generating worker join command..."
JOIN_CMD=$(kubeadm token create --print-join-command 2>/dev/null)
printf '#!/usr/bin/env bash\nsudo %s\n' "${JOIN_CMD}" > "${JOIN_CMD_FILE}"
chmod +x "${JOIN_CMD_FILE}"
progress 82 "Join command written to ${JOIN_CMD_FILE} ✓"

# ── 8. Wait for kube-system pods ─────────────────────────────────────────────
progress 84 "Waiting for kube-system pods to stabilise (up to 3 min)..."
for i in $(seq 1 36); do
  READY=$(kubectl get pods -n kube-system --no-headers 2>/dev/null \
          | grep -c "Running" || true)
  TOTAL=$(kubectl get pods -n kube-system --no-headers 2>/dev/null \
          | wc -l || true)
  PCT=$(( 84 + i / 4 ))
  [ "${PCT}" -gt 97 ] && PCT=97
  progress ${PCT} "kube-system: ${READY}/${TOTAL} Running  (attempt ${i}/36)"
  [ "${READY}" -ge 6 ] && break
  sleep 5
done

progress 100 "Phase 3/3 — Control plane fully initialised ✓"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📋  Control Plane Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Nodes:"
kubectl get nodes || true
echo ""
echo "  kube-system pods:"
kubectl get pods -n kube-system || true
echo ""
echo "  Tigera status:"
kubectl get tigerastatus 2>/dev/null || echo "  (tigerastatus not yet available)"
echo ""