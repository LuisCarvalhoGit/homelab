# 🚀 Bare-Metal Homelab: Zero Trust & Observability

[![CI/CD Pipeline](https://github.com/luiscarvalhogit/homelab/actions/workflows/deploy.yml/badge.svg)](https://github.com/luiscarvalhogit/homelab/actions/workflows/deploy.yml)
[![Infrastructure](https://img.shields.io/badge/Infrastructure-Ansible-blue)](https://www.ansible.com/)
[![Containers](https://img.shields.io/badge/Containers-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Network](https://img.shields.io/badge/Network-Tailscale-white?logo=tailscale&logoColor=black)](https://tailscale.com/)

A personal, bare-metal infrastructure project focused on **Site Reliability Engineering (SRE)** practices, **Zero Trust Architecture**, and automated deployments.

Instead of exposing services to the public internet, this homelab leverages an overlay mesh network with automated TLS provisioning and dynamic Layer 7 routing.

## 🏗️ Architecture & Tech Stack

* **Compute:** Raspberry Pi (ARM64) running a containerized stack.
* **Network & Security (Zero Trust):** Tailscale (WireGuard mesh) + MagicDNS. No inbound ports (80/443) are exposed to the public internet.
* **Ingress Controller:** Traefik v3 (dynamic L7 routing, sub-path stripping, and automatic TLS certificate resolution via the Tailscale daemon).
* **Observability:** Prometheus (time-series metrics), Node-Exporter (host metrics), and Grafana (visualization).
* **Container Management:** Portainer CE.
* **CI/CD:** GitHub Actions.
* **Configuration Management:** Ansible (host provisioning and baseline setup).

## 🔒 Security & Zero Trust Approach

To align with modern enterprise security standards, this environment implements:

1. **No Perimeter Exposure:** The router firewall blocks all inbound traffic. Access is strictly authenticated via the Tailscale VPN.
2. **Automated Internal TLS:** Traefik communicates with the `tailscaled` daemon to automatically fetch and renew valid Let's Encrypt certificates for the internal `ts.net` domain.
3. **Dynamic Secrets Management:** No hardcoded credentials or domains exist in the codebase. Passwords and domain names are injected at runtime via GitHub Actions Secrets/Variables into isolated tmpfs Docker secrets.

## 📂 Repository Structure

```text
.
├── .github/workflows/   # CI/CD pipelines (linting & SSH deployments)
├── ansible/             # Ansible playbooks and roles for base host configuration
├── core-network/        # Traefik ingress controller and routing configurations
├── core-services/       # Management services (Portainer)
├── monitoring/          # Observability stack (Prometheus, Grafana, Node-Exporter)
└── scripts/             # Bash utilities (garbage collection, watchdogs, backups)
```

## 🚀 Deployment (CI/CD)

The deployment process is fully automated via GitHub Actions, following GitOps principles:

1. **Continuous Integration (CI):** On every push, the pipeline validates Docker Compose syntax across all stacks using dummy variables.
2. **Continuous Deployment (CD):**
   * Establishes a secure SSH connection to the node.
   * Injects credentials into protected `.secrets/` files.
   * Passes the `HOMELAB_DOMAIN` environment variable in-memory to Traefik for dynamic host resolution.
   * Pulls the latest images and recreates the containers with minimal downtime.
