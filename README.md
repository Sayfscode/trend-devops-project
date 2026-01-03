Application Overview

This project deploys a web application using:

Docker Container
AWS ECR / DockerHub Registry
AWS EKS Kubernetes Cluster
Jenkins CI/CD Pipeline
Infrastructure provisioned via Terraform
Monitoring (Grafana & Prometheus)


DOCKER

Create Dockerfile:
A Dockerfile was created to containerize the application using Nginx.
Built & Tested Image
Pushed to DockerHub


TERRAFORM — Infrastructure as Code

Terraform provisions:

VPC
Subnets
IAM Roles
Security Groups
EC2 Instance (Jenkins Server)
EKS Cluster

Initialize Terraform (terraform init)
Validate & Plan  (terraform plan) 
Apply (terraform apply)


DOCKERHUB

A DockerHub repository was created to store the image used in Kubernetes deployment.

Repository name: sayfops/trend-devops-app


Kubernetes on AWS EKS

 Confirm Cluster
 Deploy Application
 Verify:  kubectl get pods
          kubectl get svc

The service exposes a LoadBalancer, providing a public URL.


VERSION CONTROL (GitHub)

Code pushed to GitHub using CLI
.gitignore & .dockerignore added
Webhook configured for Jenkins


Jenkins – CI/CD

Installed Plugins
	•	Docker
	•	Kubernetes
	•	Pipeline
	•	Git

 Github Webhook Enabled

Triggers build on every push.
Pipeline defined via Jenkinsfile


Monitoring:

installed Grafana had errors with Prometheus during installation






**Application URL:**
http://k8s-default-trending-5d84c673c2-46634345.ap-south-1.elb.amazonaws.com

**Load Balancer ARN:**
arn:aws:elasticloadbalancing:ap-south-1:496009355984:loadbalancer/app/k8s-default-trending-5d84c673c2/f32c8a37ec8dc94f
