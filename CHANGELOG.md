# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-06-17

### Added
- Fully automated multi-node Kubernetes cluster provisioning via Vagrant and VirtualBox.
- Single-file cluster topology configuration via `cluster.yaml`.
- Calico CNI v3.31.5 support via Tigera operator.
- Sequential provisioning: OS prep → Kubernetes install → cluster init / join.
- Dynamic Kubernetes version detection (latest stable).
- Built-in test deployment script (`05-test.sh`).
- Progress bar output during provisioning.
- VirtualBox host-only networking on `192.168.56.x`.
- Professional documentation site built with MkDocs Material.
- Custom documentation homepage template and styling overrides with dark/light mode toggle.
- CI/CD pipeline for automated markdown linting, strict documentation building, and deployment to GitHub Pages.
