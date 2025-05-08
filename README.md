# PostgreSQL Kubernetes Assessment

This repository contains Terraform code and Helm configuration to deploy
a minimal PostgreSQL instance into an AWS EKS cluster, complete with:
- VPC and networking
- EKS cluster and node groups
- AWS EBS CSI driver and StorageClass
- Kubernetes namespace and Secret for database credentials
- Helm release for Bitnami PostgreSQL with persistence and resource limits
