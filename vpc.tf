# -----------------------------------------------------------------------------
# File: terraform/vpc.tf
# Purpose: Defines the AWS VPC for the NHS patient monitoring system.
#          This module creates a two-AZ VPC with public and private subnets,
#          NAT gateway for outbound internet access, and DNS support enabled.
#          It sits upstream of the Kubernetes cluster, providing networking
#          infrastructure for the PostgreSQL database and other services.
# -----------------------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"  # Use the official AWS VPC module
  version = "~> 5.0"                       # Lock to major version 5.x for stability

  # VPC identification and addressing
  name = "nhs-patient-monitoring-vpc"      # Friendly name for resource tagging and identification
  cidr = var.vpc_cidr                        # Root CIDR block (e.g., "10.0.0.0/16")

  # Availability Zones and subnet configuration
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)  # Use first two AZs
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]                        # Public-facing subnets
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]                    # Private subnets for databases and backend

  # NAT Gateway configuration for outbound internet from private subnets
  enable_nat_gateway = true      # Provision NAT gateway(s)
  single_nat_gateway = true      # Use a single NAT gateway for cost-efficiency

  # DNS configuration to support AWS services and hostnames
  enable_dns_support   = true    # Enable DNS resolution in the VPC
  enable_dns_hostnames = true    # Assign public DNS names to EC2 instances

  # Tagging all resources for easy identification and cost allocation
  tags = {
    Project = "nhs-patient-monitoring"  # Project name tag
    Owner   = "chido"                   # Owner identifier tag
  }
}
