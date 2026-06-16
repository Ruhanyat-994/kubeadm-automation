# -*- mode: ruby -*-
# vi: set ft=ruby :
# =============================================================================
# Vagrantfile – Dynamic Kubernetes Cluster
# All cluster settings are read from cluster.yaml.
# Edit cluster.yaml to add/remove nodes or change resources.
# =============================================================================

require 'yaml'

# ── Load cluster configuration ────────────────────────────────────────────────
CONFIG_FILE = File.join(File.dirname(__FILE__), "cluster.yaml")
abort("ERROR: cluster.yaml not found. Please create it before running vagrant up.") unless File.exist?(CONFIG_FILE)

cfg = YAML.load_file(CONFIG_FILE)
cluster  = cfg["cluster"]
nodes    = cfg["nodes"]

# ── Validate: exactly one control plane ──────────────────────────────────────
cp_nodes = nodes.select { |n| n["role"] == "controlplane" }
abort("ERROR: cluster.yaml must define exactly one node with role: controlplane") unless cp_nodes.length == 1

CONTROL_PLANE_IP  = cp_nodes[0]["ip"]
POD_CIDR          = cluster["pod_cidr"]
SERVICE_CIDR      = cluster["service_cidr"]
CALICO_VERSION    = cluster["calico_version"]
BOX_IMAGE         = cluster["box"]
TOTAL_NODES       = nodes.length
WORKER_COUNT      = nodes.select { |n| n["role"] == "worker" }.length

# ── Progress helpers ──────────────────────────────────────────────────────────
# Each node runs 4 phases. We track approximate percentage per phase.
# Phase weights (per node): common=15%, kubernetes=35%, role=45%, done=5%
PHASE_LABELS = {
  "common"       => "System setup (swap, modules, sysctl)",
  "kubernetes"   => "Installing containerd + Kubernetes packages",
  "controlplane" => "Initialising control plane + Calico CNI",
  "worker"       => "Joining worker node to cluster"
}

Vagrant.configure("2") do |config|
  config.vm.box = BOX_IMAGE

  # Keep /vagrant synced so join-command.sh is shared across VMs
  config.vm.synced_folder ".", "/vagrant", disabled: false

  nodes.each_with_index do |node, node_index|
    config.vm.define node["name"] do |cfg_vm|
      cfg_vm.vm.hostname = node["name"]
      cfg_vm.vm.network "private_network", ip: node["ip"]

      cfg_vm.vm.provider "virtualbox" do |vb|
        vb.name   = node["name"]
        vb.memory = node["memory"]
        vb.cpus   = node["cpus"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
      end

      # ── Banner: node starting ──────────────────────────────────────────────
      cfg_vm.vm.provision "shell", name: "banner-start", inline: <<~SHELL
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║      Provisioning: #{node["name"].ljust(20)}  [Node #{node_index + 1}/#{TOTAL_NODES}]        ║"
        echo "║      Role: #{node["role"].ljust(15)}  IP: #{node["ip"]}              ║"
        echo "║      RAM:  #{node["memory"].to_s.ljust(6)} MB          CPUs: #{node["cpus"]}                       ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
      SHELL

      # ── Step 1: Common setup (15%) ─────────────────────────────────────────
      cfg_vm.vm.provision "shell",
        name:  "common",
        path:  "scripts/01-common.sh",
        env: {
          "PRIMARY_IP"    => node["ip"],
          "NODE_NAME"     => node["name"],
          "NODE_INDEX"    => (node_index + 1).to_s,
          "TOTAL_NODES"   => TOTAL_NODES.to_s,
          "PHASE"         => "1",
          "PHASE_TOTAL"   => "3"
        }

      # ── Step 2: Kubernetes packages (35%) ─────────────────────────────────
      cfg_vm.vm.provision "shell",
        name:  "kubernetes",
        path:  "scripts/02-kubernetes.sh",
        env: {
          "PRIMARY_IP"    => node["ip"],
          "NODE_NAME"     => node["name"],
          "NODE_INDEX"    => (node_index + 1).to_s,
          "TOTAL_NODES"   => TOTAL_NODES.to_s,
          "PHASE"         => "2",
          "PHASE_TOTAL"   => "3"
        }

      # ── Step 3: Role-specific (45%) ────────────────────────────────────────
      if node["role"] == "controlplane"
        cfg_vm.vm.provision "shell",
          name:  "controlplane",
          path:  "scripts/03-controlplane.sh",
          env: {
            "PRIMARY_IP"      => node["ip"],
            "NODE_NAME"       => node["name"],
            "NODE_INDEX"      => (node_index + 1).to_s,
            "TOTAL_NODES"     => TOTAL_NODES.to_s,
            "WORKER_COUNT"    => WORKER_COUNT.to_s,
            "POD_CIDR"        => POD_CIDR,
            "SERVICE_CIDR"    => SERVICE_CIDR,
            "CALICO_VERSION"  => CALICO_VERSION,
            "PHASE"           => "3",
            "PHASE_TOTAL"     => "3"
          }
      else
        cfg_vm.vm.provision "shell",
          name:  "worker",
          path:  "scripts/04-worker.sh",
          env: {
            "NODE_NAME"     => node["name"],
            "NODE_INDEX"    => (node_index + 1).to_s,
            "TOTAL_NODES"   => TOTAL_NODES.to_s,
            "PHASE"         => "3",
            "PHASE_TOTAL"   => "3"
          }
      end

      # ── Banner: node done ──────────────────────────────────────────────────
      pct = (((node_index + 1).to_f / TOTAL_NODES) * 100).round
      cfg_vm.vm.provision "shell", name: "banner-done", inline: <<~SHELL
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║       #{node["name"].ljust(14)} provisioned!   Overall: #{pct.to_s.rjust(3)}% complete   ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
      SHELL
    end
  end
end