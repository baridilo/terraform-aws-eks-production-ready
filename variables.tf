variable "aws_region" {
  description = "AWS Region for all resources."
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Short lowercase name used as the resource name prefix."
  type        = string
  default     = "eks-portfolio"
}

variable "environment" {
  description = "Environment tag."
  type        = string
  default     = "demo"
}

variable "vpc_cidr" {
  description = "CIDR assigned to the VPC."
  type        = string
  default     = "10.42.0.0/16"
}

variable "cluster_version" {
  description = "EKS Kubernetes minor version; verify regional availability before applying."
  type        = string
  default     = "1.33"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
  validation {
    condition     = var.node_desired_size >= 1 && var.node_desired_size <= 5
    error_message = "Set desired size between 1 and 5."
  }
}

variable "admin_cidrs" {
  description = "Explicit CIDR allowlist for public EKS Kubernetes API access. Empty disables the public endpoint."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for c in var.admin_cidrs : can(cidrhost(c, 0)) && c != "0.0.0.0/0" && c != "::/0"])
    error_message = "Provide specific, valid CIDRs; unrestricted internet access is not allowed."
  }
}
