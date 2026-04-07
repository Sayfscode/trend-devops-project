# Trend App — Full DevOps Pipeline

End-to-end DevOps deployment of a web application using Terraform, Jenkins CI/CD, Docker, and Kubernetes on AWS EKS with monitoring via Grafana and Prometheus.

> **Note:** The frontend application was provided as a pre-built artifact. This project focuses on the **infrastructure and DevOps pipeline** — not application development.

## Architecture

```
Developer pushes code to GitHub
         |
         v
GitHub Webhook triggers Jenkins
         |
         v
Jenkins CI/CD Pipeline
  |-- Checks out code
  |-- Builds Docker image (tagged with build number)
  |-- Pushes to DockerHub
  |-- Updates EKS deployment with new image
         |
         v
AWS EKS Kubernetes Cluster
  |-- Deployment: 2 replicas with health probes
  |-- Service: NodePort
  |-- Ingress: AWS ALB (Application Load Balancer)
         |
         v
Monitoring
  |-- Prometheus (metrics collection)
  |-- Grafana (dashboards)
```

## Infrastructure (Terraform)

All AWS infrastructure is provisioned as code:

| Resource | Purpose |
|----------|---------|
| VPC | Isolated network with public subnet |
| Internet Gateway | Internet access for the VPC |
| Security Group | SSH restricted to admin IP, Jenkins UI on port 8080 |
| EC2 Instance | Jenkins server (auto-installs Java, Jenkins, Docker) |

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## CI/CD Pipeline (Jenkins)

The pipeline triggers automatically via GitHub webhook on every push:

1. **Checkout** — Pulls latest code from GitHub
2. **Build** — Builds Docker image tagged with Jenkins build number
3. **Push** — Authenticates to DockerHub and pushes the image
4. **Deploy** — Updates the EKS deployment with the new image and waits for rollout

## Kubernetes Deployment

| Manifest | Purpose |
|----------|---------|
| `k8s/deployment.yaml` | 2 replicas, resource limits, liveness/readiness probes |
| `k8s/service.yaml` | NodePort service for internal routing |
| `k8s/ingress.yaml` | AWS ALB Ingress for external internet access |
| `k8s/alb-patch.yaml` | Resource limits for the ALB controller |

## Monitoring

- **Prometheus** — Collects metrics from the cluster and application
- **Grafana** — Visualizes metrics on custom dashboards

## Project Structure

```
.
├── terraform/                 # Infrastructure as Code
│   ├── main.tf                # VPC, subnet, SG, EC2 (Jenkins)
│   ├── variables.tf           # Parameterized inputs
│   ├── outputs.tf             # Jenkins IP and URL
│   └── terraform.tfvars.example
├── k8s/                       # Kubernetes manifests
│   ├── deployment.yaml        # App deployment with health probes
│   ├── service.yaml           # NodePort service
│   ├── ingress.yaml           # ALB Ingress
│   └── alb-patch.yaml         # ALB controller resource limits
├── Trend/                     # Pre-built frontend application
├── screenshots/               # Deployment evidence
├── Dockerfile                 # Container image (Nginx, non-root)
├── Jenkinsfile                # CI/CD pipeline definition
├── nginx.conf                 # Nginx config (gzip, security headers)
├── iam_policy.json            # IAM policy for ALB Ingress Controller
└── README.md
```

## Key DevOps Practices

- **Infrastructure as Code** — All AWS resources provisioned via Terraform with variables (no hardcoded values)
- **SSH restricted** — Security group allows SSH only from the admin's IP address
- **Image versioning** — Each Docker build is tagged with Jenkins build number for traceability
- **Health probes** — Kubernetes liveness and readiness probes detect and recover from failures
- **Resource limits** — CPU and memory limits prevent pods from exhausting cluster resources
- **Non-root container** — Nginx runs as non-root user for security
- **Automated deployments** — GitHub webhook triggers Jenkins on every push, zero manual steps
- **Monitoring** — Prometheus and Grafana for cluster and application observability

## Screenshots

| Step | Screenshot |
|------|-----------|
| Local Testing | ![Local](screenshots/01-app%20running%20in%20localhost%203000.png) |
| EC2 Instance | ![EC2](screenshots/02-EC2%20instance%20running.png) |
| Jenkins Active | ![Jenkins](screenshots/03-Jenkins%20active.png) |
| Load Balancer | ![ALB](screenshots/04-Application%20LoadBalancer.png) |
| Kubernetes Nodes | ![Nodes](screenshots/05-kubectl%20get%20nodes.png) |
| Jenkins Pipeline | ![Pipeline](screenshots/09-Jenkins%20Dashboard.png) |
| GitHub Webhook | ![Webhook](screenshots/10-Github%20Webhook.png) |
| DockerHub | ![DockerHub](screenshots/11-DockerHub%20Repo.png) |
| Grafana | ![Grafana](screenshots/13-Grafana%20Dashboard.png) |

## Local Development

```bash
# Build the Docker image
docker build -t trend-devops-app .

# Run locally
docker run -p 80:80 trend-devops-app

# Access at http://localhost
```
