---
title: Prerequisites
description: Software and hardware prerequisites for running KubeAuto
---

# Prerequisites

Before deploying a Kubernetes cluster with KubeAuto, ensure your system meets the following software and hardware requirements.

---

## Software Requirements

### VirtualBox

KubeAuto uses VirtualBox as the hypervisor to create and manage virtual machines.

!!! info "Minimum Version"
    VirtualBox **6.1** or newer is required. VirtualBox 7.x is recommended.

=== "Windows"

    1. Download the installer from [virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads)
    2. Run the installer and follow the prompts
    3. Restart your computer if prompted
    4. Verify installation:
    ```powershell
    VBoxManage --version
    ```

=== "macOS"

    Using Homebrew:
    ```bash
    brew install --cask virtualbox
    ```

    Or download from [virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads).

    Verify:
    ```bash
    VBoxManage --version
    ```

=== "Linux (Ubuntu/Debian)"

    ```bash
    sudo apt update
    sudo apt install -y virtualbox virtualbox-ext-pack
    ```

    Verify:
    ```bash
    VBoxManage --version
    ```

=== "Linux (Fedora/RHEL)"

    ```bash
    sudo dnf install -y VirtualBox
    ```

---

### Vagrant

Vagrant orchestrates the VM lifecycle and provisioning.

!!! info "Minimum Version"
    Vagrant **2.3** or newer is required.

=== "Windows"

    1. Download the installer from [vagrantup.com/downloads](https://developer.hashicorp.com/vagrant/downloads)
    2. Run the `.msi` installer
    3. Restart your terminal
    4. Verify:
    ```powershell
    vagrant --version
    ```

=== "macOS"

    ```bash
    brew install --cask vagrant
    ```

    Verify:
    ```bash
    vagrant --version
    ```

=== "Linux (Ubuntu/Debian)"

    ```bash
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install -y vagrant
    ```

=== "Linux (Fedora/RHEL)"

    ```bash
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
    sudo dnf install -y vagrant
    ```

---

### Git

Git is needed to clone the repository.

=== "Windows"

    Download from [git-scm.com](https://git-scm.com/download/win) or use winget:
    ```powershell
    winget install Git.Git
    ```

=== "macOS"

    ```bash
    brew install git
    ```

=== "Linux"

    ```bash
    sudo apt install -y git    # Debian/Ubuntu
    sudo dnf install -y git    # Fedora/RHEL
    ```

---

## Hardware Requirements

| Resource   | Minimum        | Recommended     | Notes                                   |
|-----------|----------------|-----------------|------------------------------------------|
| **RAM**   | 8 GB free      | 16 GB+          | Each worker VM uses 1.5 GB by default    |
| **CPU**   | 4 cores        | 6+ cores        | Control plane requires 2 CPUs minimum    |
| **Disk**  | 30 GB free     | 50 GB+          | VirtualBox VM images need disk space     |

---

## Network Requirements

- **Internet access** is required during the first provisioning run (packages are downloaded from the internet)
- Subsequent starts (`vagrant up` after `vagrant suspend`) do not require internet
- Port **22** (SSH) is used internally by Vagrant — no manual firewall changes needed

---

## Verification Checklist

Run these commands to verify all prerequisites are installed:

```bash
VBoxManage --version
vagrant --version
git --version
```

All three must return a version number without errors.

!!! tip "Next Step"
    Once prerequisites are installed, proceed to the [Quick Start](quick-start.md) guide.
