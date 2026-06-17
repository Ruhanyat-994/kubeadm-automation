---
title: Contributing
description: How to contribute to KubeAuto
---

# Contributing

Thank you for your interest in contributing to KubeAuto! This guide explains how to get involved.

---

## Ways to Contribute

- 🐛 **Report bugs** — open a [GitHub Issue](https://github.com/Ruhanyat-994/kubeadm-automation/issues)
- 💡 **Request features** — describe your idea in a GitHub Issue
- 📝 **Improve documentation** — fix typos, add examples, clarify instructions
- 🔧 **Submit code** — fix bugs or implement new features via Pull Requests

---

## Development Setup

1. Fork the repository on GitHub
2. Clone your fork:
    ```bash
    git clone https://github.com/<your-username>/kubeadm-automation.git
    cd kubeadm-automation
    ```
3. Create a feature branch:
    ```bash
    git checkout -b feature/your-feature-name
    ```
4. Make your changes
5. Commit following the [Conventional Commits](#commit-messages) format
6. Push and open a Pull Request against the `develop` branch

---

## Branch Naming

| Branch Pattern     | Use For                     |
|-------------------|-----------------------------|
| `feature/<name>`  | New features                |
| `fix/<name>`      | Bug fixes                   |
| `docs/<name>`     | Documentation changes only  |

---

## Commit Messages

We use **Conventional Commits**:

```
<type>(<scope>): <short description>
```

| Type       | When to Use                        |
|------------|-------------------------------------|
| `feat`     | New feature                        |
| `fix`      | Bug fix                            |
| `docs`     | Documentation only                 |
| `refactor` | Code change with no functional diff |
| `chore`    | Maintenance (CI, deps, config)     |
| `test`     | Adding or updating tests           |

### Examples

```
feat(cluster): add pinned kubernetes_version field to cluster.yaml
fix(worker): handle expired join token on vagrant up after halt
docs(readme): add architecture diagram
chore(ci): add shellcheck to lint workflow
```

---

## Pull Request Guidelines

1. Target the `develop` branch (not `main`)
2. Write a clear description of what changed and why
3. Ensure your changes don't break existing functionality
4. Follow the commit message convention
5. Keep PRs focused — one feature or fix per PR

---

## Code Style

### Shell Scripts

- Use `#!/usr/bin/env bash`
- Enable strict mode: `set -euo pipefail`
- Use meaningful variable names
- Add comments for non-obvious logic

### YAML

- Use 2-space indentation
- Quote string values
- Add comments for configuration sections

---

## Questions?

Open an issue or start a discussion on the [GitHub repository](https://github.com/Ruhanyat-994/kubeadm-automation).
