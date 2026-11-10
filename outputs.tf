output "cluster_name" {
  description = "EKS cluster name."
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint (private by default)."
  value       = aws_eks_cluster.main.endpoint
}

output "region" {
  value = var.aws_region
}

output "node_group_name" {
  value = aws_eks_node_group.main.node_group_name
}

output "configure_kubectl" {
  description = "Run from a host with access to the private endpoint."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
