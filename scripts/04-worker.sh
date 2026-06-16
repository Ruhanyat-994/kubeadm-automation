#!/usr/bin/env bash
# =============================================================================
# 04-worker.sh – Run on worker nodes
# Waits for the join command written by controlplane, then joins the cluster
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
echo "  🔗  [${NODE_NAME}] Phase 3/3 — Joining Cluster"
echo "      Node ${NODE_INDEX}/${TOTAL_NODES}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

JOIN_CMD_FILE="/vagrant/join-command.sh"

# ── Wait for join command ─────────────────────────────────────────────────────
progress 5 "Waiting for join-command.sh from control plane..."
ATTEMPTS=0
until [ -f "${JOIN_CMD_FILE}" ]; do
  ATTEMPTS=$((ATTEMPTS + 1))
  if [ "${ATTEMPTS}" -gt 60 ]; then
    echo ""
    echo "  ❌  ERROR: Timed out waiting for ${JOIN_CMD_FILE} after 5 minutes."
    echo "      Ensure the controlplane VM was provisioned first."
    echo "      Tip: Run 'vagrant provision controlplane' and retry."
    exit 1
  fi
  PCT=$(( 5 + ATTEMPTS ))
  [ "${PCT}" -gt 40 ] && PCT=40
  progress ${PCT} "Waiting... attempt ${ATTEMPTS}/60 (control plane may still be init-ing)"
  sleep 5
done

progress 45 "join-command.sh found ✓"

# ── Execute join command ──────────────────────────────────────────────────────
progress 50 "Executing kubeadm join..."
bash "${JOIN_CMD_FILE}" 2>&1 | grep -E "(node|error|Error|token|success|Running)" || true
progress 100 "Phase 3/3 — Worker joined the cluster ✓"
echo ""