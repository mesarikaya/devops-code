/* output "cluster_id" {
  description = "Kubernetes Cluster Id"
  value       = module.eks.cluster_id
}
 */
/* output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
} */

output "endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_id" {
  description = "Kubernetes Cluster Id"
  value       = aws_eks_cluster.eks_cluster.id
}
