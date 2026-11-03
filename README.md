# homelab
Folder structure:

homelab/
├── .github/                    # (Futuro) Aqui vão viver as pipelines de CI/CD (GitHub Actions)
│   └── workflows/
│       └── deploy-apexgrid.yml 
│
├── core-network/               # A "Espinha Dorsal"
│   └── docker-compose.yml      # Apenas Traefik/Nginx e Cloudflared. Gere o tráfego que entra.
│
├── monitoring/                 # Stack coesa (tudo no mesmo compose)
│   ├── docker-compose.yml      # Grafana + Prometheus + Node Exporter
│   ├── .env                    # Variáveis (ignorado no git)
│   ├── prometheus/             # Ficheiros de configuração
│   │   └── prometheus.yml
│   └── grafana/
│       └── provisioning/       # Para os dashboards como código
│
├── core-services/              # Infraestrutura base partilhada
│   ├── portainer/
│   │   └── docker-compose.yml
│   └── postgres-shared/        # BD central (se não quiseres uma BD por app)
│       └── docker-compose.yml
│
├── apps/                       # O teu software (Deploy via CI/CD)
│   ├── apexgrid/
│   │   ├── docker-compose.yml  # A API e frontend do ApexGrid
│   │   └── .env                
│   └── load-balancer/          # O teu projeto em C#
│       └── docker-compose.yml
│
├── scripts/                    # Automação do Host
│   ├── backup.sh               # Cronjobs para backup dos volumes Docker
│   └── init-server.sh          # Script de bootstrap (Swap, Swappiness, Tailscale, etc)
│
├── .gitignore
└── README.md                   # Documentação da infra (IPs, Portas, Comandos)
