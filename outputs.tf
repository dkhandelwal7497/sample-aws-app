output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "kubeconfig" {
  description = "Kubeconfig for the EKS cluster"
  value       = module.eks.kubeconfig
  sensitive   = true
}

output "istio_ingress_ip" {
  description = "The public IP address of the Istio ingress gateway"
  value       = "You need to run 'kubectl get svc istio-ingressgateway -n istio-system' to get the public IP."
}
