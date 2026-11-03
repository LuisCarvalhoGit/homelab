# Raspberry Pi Homelab

Infrastructure as Code for a homelab on a Raspberry Pi, using Docker Compose, Traefik (Reverse Proxy), Prometheus/Grafana/Node Exporter (Observability) and Portainer (Management).


## Estrutura do Repositório

```text
homelab/
├── core-network/          # (Traefik, Reverse Proxy, TLS)
├── core-services/         # Central management services (Portainer CE)
├── monitoring/            # Observability stack (Prometheus, Grafana, Node Exporter)
├── apps/                  # Custom Apps [Futuro]
├── scripts/               # Scripts de automação e bootstrap do host [Futuro] 
├── .gitignore
└── README.md