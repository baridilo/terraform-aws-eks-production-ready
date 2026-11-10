# AWS EKS Infrastructure with Terraform

**Portfolio infrastructure-as-code project** demonstrating a two-AZ Amazon EKS cluster with private worker nodes and Terraform-managed networking, IAM, logging, and Kubernetes workloads.

> This is a **demonstration project**, not a record of a deployed production environment. No AWS infrastructure has been created by this repository. `terraform apply` incurs real AWS costs.

## Architecture

```text
                        AWS Region
                 +----------------------+
                 | VPC 10.42.0.0/16     |
Internet ----->  | Internet Gateway     |
                 |          |           |
                 | Public subnet AZ-a   | --> NAT Gateway (single-AZ demo)
                 | Public subnet AZ-b   |           |
                 |          |           |           |
                 | Private subnet AZ-a <-----------+
                 | Private subnet AZ-b <-----------+
                 |          |           |
                 | EKS managed nodes    |
                 | EKS private API      |
                 +----------------------+
```

**What is implemented**

- Terraform AWS provider configuration, variables and outputs.
- VPC with public/private subnets across two availability zones, route tables, Internet Gateway and one NAT Gateway.
- EKS control plane with Kubernetes API private by default, optional allowlisted public access and CloudWatch control-plane logs with 30-day retention.
- EKS managed node group in private subnets with configurable desired capacity and managed IAM roles.
- A small, non-root Kubernetes Deployment and internal ClusterIP Service in `kubernetes/demo-app.yaml`.
- GitHub Actions pull request checks for formatting, Terraform initialization, and validation; **no automatic apply**.

## Prerequisites

- Terraform >= 1.6, AWS CLI, kubectl, and AWS permissions to create VPC/EKS/IAM/EC2/CloudWatch infrastructure.
- AWS account with enough EC2 and Elastic IP quotas.
- An authenticated connection into the VPC (for example a VPN, bastion or suitably configured SSM-managed host) to reach the **private Kubernetes API endpoint**.

## Local usage

```bash
git clone https://github.com/baridilo/terraform-aws-eks-production-ready.git
cd terraform-aws-eks-production-ready
cp terraform.tfvars.example terraform.tfvars
terraform fmt -recursive
terraform init
terraform validate
terraform plan
# Review all proposed changes and estimated cost before:
# terraform apply
```

After deployment, from a machine with network access to the EKS API endpoint:

```bash
aws eks update-kubeconfig --region eu-west-1 --name eks-portfolio-demo
kubectl apply -f kubernetes/demo-app.yaml
kubectl get pods,svc
```

### Access choice

By default `admin_cidrs = []` makes the public Kubernetes API endpoint **disabled**, while the private endpoint is enabled. You cannot administer the cluster from a standard laptop outside the VPC without a private network path. For a controlled public endpoint, set `admin_cidrs` to explicit trusted source IP /32 addresses before applying; never use unrestricted CIDRs. Restricting the endpoint does not replace least-privilege IAM or Kubernetes RBAC.

### Costs and limitations

- **Cost warning:** EKS control plane, EC2 nodes, NAT Gateway, public IPv4 address, traffic, and CloudWatch logging are billable. Review the AWS pricing pages and your estimated `terraform plan` before deployment.
- The single NAT Gateway is a **cost-saving portfolio tradeoff** and a single-AZ egress dependency. Production designs commonly use one NAT Gateway per AZ or appropriate VPC endpoints.
- IAM for the VPC CNI currently uses a node-role policy to keep this example simple. For production, move CNI permissions to a dedicated EKS Pod Identity/IAM role.
- The code doesn't provision a remote encrypted state backend, full monitoring/alerts, multi-environment pipelines, external secret management, or production-grade disaster recovery.
- Verify the configured EKS Kubernetes version and AMI availability in the selected region.

### Cleanup

Delete sample app resources, then run `terraform destroy` using the **same Terraform state** and AWS credentials. Inspect AWS for anything left behind, particularly networking, EKS and logs. Do not delete the Terraform state until cleanup is verified.

## Pull request

The original implementation is intentionally proposed via `feature/eks-infrastructure`, making the design, code changes, and review process visible. The pull request documents the scope and verification status.