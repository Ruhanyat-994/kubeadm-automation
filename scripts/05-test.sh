#!/usr/bin/env bash
# =============================================================================
# 05-test.sh – Run on controlplane ONLY (after all workers have joined)
# Deploys a simple Apache httpd web app, exposes it via NodePort,
# and prints the browser URL so you can view it directly.
# =============================================================================
set -euo pipefail

export KUBECONFIG=/home/vagrant/.kube/config

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        Deploying Test Workload (Apache httpd)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Deploy Apache httpd ────────────────────────────────────────────────────
echo "[test] Creating httpd deployment (2 replicas)..."
kubectl create deployment webapp --image=httpd:alpine --replicas=2

echo "[test] Waiting for deployment to become available (up to 2 min)..."
kubectl wait deployment webapp \
  --for=condition=Available=True \
  --timeout=120s

# ── 2. Expose via NodePort ────────────────────────────────────────────────────
echo "[test] Exposing webapp as NodePort on port 80..."
kubectl expose deployment webapp --type=NodePort --port=80

# ── 3. Get NodePort and worker IPs ────────────────────────────────────────────
PORT=$(kubectl get service webapp \
         -o jsonpath='{.spec.ports[0].nodePort}')

# Get all worker node IPs dynamically from the cluster
WORKER_IPS=$(kubectl get nodes \
  --selector='!node-role.kubernetes.io/control-plane' \
  -o jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address}{"\n"}{end}' \
  2>/dev/null || true)

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║      Cluster test deployment complete!                       ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  NodePort assigned: ${PORT}"
echo ""
echo "  Test with curl from inside this VM:"
while IFS= read -r ip; do
  [ -z "${ip}" ] && continue
  echo "    curl http://${ip}:${PORT}"
done <<< "${WORKER_IPS}"
echo ""
echo "  Open in your browser (VirtualBox private network):"
while IFS= read -r ip; do
  [ -z "${ip}" ] && continue
  echo "    http://${ip}:${PORT}"
done <<< "${WORKER_IPS}"
echo ""
echo "  Cluster nodes:"
kubectl get nodes -o wide
echo ""
echo "  All pods:"
kubectl get pods -o wide
echo ""
echo "  Service:"
kubectl get svc webapp