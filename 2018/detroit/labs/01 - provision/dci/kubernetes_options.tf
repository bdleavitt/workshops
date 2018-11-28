variable "enable_kubernetes_azure_disk" {
  description = "Setup kubernetes with resources necessary to provision Azure Disk storage"
  default     = false
}

variable "enable_kubernetes_azure_file" {
  description = "Setup kubernetes with the ability to provision Azure Files"
  default     = false
}

variable "enable_kubernetes_azure_load_balancer" {
  description = "Setup kubernetes with the ability to provision and manage Azure Load Balancers"
  default     = false
}

variable "enable_kubernetes_nfs_storage" {
  description = "Ensure that the nodes have NFS support installed"
  default     = false
}

variable "kubernetes_orchestrator" {
  description = "Version of the kubernetes orchestrator to tag instances with"
  default     = "1.8.11"
}

variable "kubernetes_pod_cidr" {
  description = "A subset of the subnet for the network.  See variables.tf"
  default     = "172.31.0.0/16"
}

variable "enable_kubernetes_cloud_provider" {
  description = "Explicitly enable Kubernetes Cloud provider"
  default     = false
}
