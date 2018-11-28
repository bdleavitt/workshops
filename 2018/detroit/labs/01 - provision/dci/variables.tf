# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure subscription ID"
}

variable "client_id" {
  description = "Azure service principal app ID"
}

variable "client_secret" {
  description = "Azure service principal app secret"
}

variable "tenant_id" {
  description = "Azure tenant ID"
}

data "tls_public_key" "gen" {
  private_key_pem = "${file(var.ssh_private_key_path)}"
}

variable "ssh_key_path" {
  description = "Path to SSH Pub key file"
  default     = ""
}

locals {
  # ternary operations are somewhat broken in terraform https://github.com/hashicorp/terraform/issues/11566
  ssh_pub_key = "${var.ssh_key_path != "" ?  file(coalesce(var.ssh_key_path,"/dev/null")) : data.tls_public_key.gen.public_key_openssh }"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "vnet_addr_space" {
  description = "Virtual network address space"
  default     = ["172.31.0.0/16"]
}

variable "subnet_prefix" {
  description = "Subnet prefix"
  default     = "172.31.0.0/16"
}

variable "azure_nic_ips_count" {
  description = "UCP 3.0: Number of IPs to allocate per nic"
  default     = "20"
}

# Linux nodes disk
variable "linux_manager_os_disk_type" {
  description = "Type of OS disk for managers (Standard or Premium)"
  default     = "Premium_LRS"
}

variable "linux_manager_os_disk_cache" {
  description = "Type of OS disk for managers (Standard or Premium)"
  default     = "None"
}

variable "linux_manager_data_disk_type" {
  description = "Type of data disk for managers (Standard or Premium)"
  default     = "Standard_LRS"
}

variable "linux_manager_data_disk_size" {
  description = "Size of data disks for managers"
  default     = "10"
}

variable "linux_manager_data_disk_cache" {
  description = "Caching of data disks for managers"
  default     = "None"
}

variable "linux_worker_os_disk_type" {
  description = "Type of OS disk for Linux workers (Standard or Premium)"
  default     = "Premium_LRS"
}

variable "linux_worker_os_disk_cache" {
  description = "Type of OS disk for Linux workers (Standard or Premium)"
  default     = "None"
}

variable "linux_worker_data_disk_type" {
  description = "Type of data disk for workers (Standard or Premium)"
  default     = "Standard_LRS"
}

variable "linux_worker_data_disk_size" {
  description = "Size of data disks for Linux workers"
  default     = "10"
}

variable "linux_worker_data_disk_cache" {
  description = "Caching of data disks for Linux workers"
  default     = "None"
}

# Windows nodes disk
variable "windows_worker_os_disk_type" {
  description = "Type of OS disk for Windows workers (Standard or Premium)"
  default     = "Premium_LRS"
}

variable "windows_worker_os_disk_cache" {
  description = "Type of OS disk for Windows workers (Standard or Premium)"
  default     = "None"
}

variable "windows_worker_data_disk_type" {
  description = "Type of data disk for Windows workers (Standard or Premium)"
  default     = "Standard_LRS"
}

variable "windows_worker_data_disk_size" {
  description = "Size of data disks for Windows workers"
  default     = "10"
}

variable "windows_worker_data_disk_cache" {
  description = "Caching of data disks for Windows workers"
  default     = "None"
}

variable "platform_fault_domain_count" {
  description = "Number of fault domains that are used"
  default     = 3
}

variable "enable_load_balancers" {
  description = "Globally enable/disable load balancers for this cluster"
  default     = true
}

variable "resource_tags" {
  description = "Additional tags to apply to all resources"
  type        = "map"
  default     = {}
}
