# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS for VMSS module
# ---------------------------------------------------------------------------------------------------------------------

variable "create" {
  description = "set to 1 to create resources, 0 otherwise"
}

variable "rg_name" {
  description = "name of the Azure resource group"
}

variable "location" {
  description = "location of the Azure LB"
}

variable "lb_pool_name" {
  description = "load balancer pool name"
}

variable "lb_fe_ip_name" {
  description = "name of the frontend IP resource"
}

variable "lb_name" {
  description = "name of the lb resource"
}

variable "dns_prefix" {
  description = "dns prefix of the ip address resource for the lb"
}

variable "fe_ip_cfg_name" {
  description = "frontend ip name"
}

variable "probe_port" {
  description = "port"
}
