# Ansible Inventory File Path
variable "inventory_file" {
  description = "Ansible-compatible inventory file used to store the list of hosts"
  default     = "hosts"
}

# Linux User
variable "linux_user" {
  description = "The user to setup and use within the Linux vm"
  default     = "docker"
}

variable "private_key_file" {
  description = "Private key file for ssh connections to hosts"
  default     = "~/.ssh/id_rsa"
}

# Windows User
variable "windows_user" {
  description = "The user to setup and use within the Windows vm"
  default     = "Administrator"
}

variable "windows_worker_passwords" {
  description = "The passwords to use within the Windows VMs"
  type        = "list"
}

# Linux UCP Managers
variable "linux_ucp_manager_names" {
  description = "The list of Linux UCP Manager names"
  type        = "list"
  default     = []
}

variable "linux_ucp_manager_ips" {
  description = "The list of Linux UCP Manager IPs"
  type        = "list"
  default     = []
}

# Linux DTR Workers
variable "linux_dtr_worker_names" {
  description = "The list of Linux DTR names"
  type        = "list"
  default     = []
}

variable "linux_dtr_worker_ips" {
  description = "The list of Linux DTR IPs"
  type        = "list"
  default     = []
}

# Linux Workers
variable "linux_worker_names" {
  description = "The list of Linux Worker names"
  type        = "list"
  default     = []
}

variable "linux_worker_ips" {
  description = "The list of Linux Worker IPs"
  type        = "list"
  default     = []
}

# Windows Workers
variable "windows_worker_names" {
  description = "The list of Windows Worker names"
  type        = "list"
  default     = []
}

variable "windows_worker_ips" {
  description = "The list of Windows Worker IPs"
  type        = "list"
  default     = []
}

## Extra Instances
# Linux Database Server
variable "linux_database_names" {
  description = "The list of Linux Database names"
  type        = "list"
  default     = []
}

variable "linux_database_ips" {
  description = "The list of Linux Database IPs"
  type        = "list"
  default     = []
}

# Linux Build Server
variable "linux_build_server_names" {
  description = "The list of Linux Build Server names"
  type        = "list"
  default     = []
}

variable "linux_build_server_ips" {
  description = "The list of Linux Build Server IPs"
  type        = "list"
  default     = []
}

# Windows Database Server
variable "windows_database_names" {
  description = "The list of Windows Database names"
  type        = "list"
  default     = []
}

variable "windows_database_ips" {
  description = "The list of Windows Database IPs"
  type        = "list"
  default     = []
}

# Windows Build Server
variable "windows_build_server_names" {
  description = "The list of Windows Build Server names"
  type        = "list"
  default     = []
}

variable "windows_build_server_ips" {
  description = "The list of Windows Build Server IPs"
  type        = "list"
  default     = []
}

# Load balancers

variable "docker_ucp_lb" {
  description = "UCP load balancer DNS name"
  default     = ""
}

variable "docker_dtr_lb" {
  description = "DTR load balancer DNS name"
  default     = ""
}

variable "linux_ucp_lb_ips" {
  description = "UCP load balancer IPs"
  default     = []
}

variable "linux_ucp_lb_names" {
  description = "UCP load balancer names"
  default     = []
}

variable "linux_dtr_lb_ips" {
  description = "DTR load balancer DNS name"
  default     = []
}

variable "linux_dtr_lb_names" {
  description = "DTR load balancer names"
  default     = []
}

# Additional vars
variable "infra_stack" {
  description = "The infra stack being deployed"
  default     = ""
}

variable "cloudstor_plugin_version" {
  description = ""
  default     = ""
}

variable "docker_dtr_ca_file" {
  description = ""
  default     = ""
}

variable "docker_dtr_cert_file" {
  description = ""
  default     = ""
}

variable "docker_dtr_key_file" {
  description = ""
  default     = ""
}

variable "docker_dtr_replica_id" {
  description = ""
  default     = ""
}

variable "docker_dtr_version" {
  description = ""
  default     = ""
}

variable "docker_dtr_image_repository" {
  description = ""
  default     = ""
}

variable "docker_dtr_install_args" {
  description = ""
  default     = ""
}

variable "docker_ee_package_version" {
  description = ""
  default     = ""
}

variable "docker_ee_package_version_win" {
  description = ""
  default     = ""
}

variable "docker_ee_release_channel" {
  description = ""
  default     = ""
}

variable "docker_ee_repo" {
  description = ""
  default     = ""
}

variable "docker_ee_repository_url" {
  description = ""
  default     = ""
}

variable "docker_ee_package_url_win" {
  description = ""
  default     = ""
}

variable "docker_ee_subscriptions_centos" {
  description = ""
  default     = ""
}

variable "docker_ee_subscriptions_oracle" {
  description = ""
  default     = ""
}

variable "docker_ee_subscriptions_redhat" {
  description = ""
  default     = ""
}

variable "docker_ee_subscriptions_sles" {
  description = ""
  default     = ""
}

variable "docker_ee_subscriptions_ubuntu" {
  description = ""
  default     = ""
}

variable "docker_ee_version" {
  description = ""
  default     = ""
}

variable "docker_hub_id" {
  description = ""
  default     = ""
}

variable "docker_hub_password" {
  description = ""
  default     = ""
}

variable "docker_storage_driver" {
  description = ""
  default     = ""
}

variable "docker_storage_fstype" {
  description = ""
  default     = ""
}

variable "docker_storage_volume" {
  description = ""
  default     = ""
}

variable "docker_swarm_listen_address" {
  description = ""
  default     = ""
}

variable "docker_ucp_admin_password" {
  description = ""
  default     = ""
}

variable "docker_ucp_admin_username" {
  description = ""
  default     = ""
}

variable "docker_ucp_ca_file" {
  description = ""
  default     = ""
}

variable "docker_ucp_cert_file" {
  description = ""
  default     = ""
}

variable "docker_ucp_key_file" {
  description = ""
  default     = ""
}

variable "docker_ucp_image_repository" {
  description = ""
  default     = ""
}

variable "docker_ucp_install_args" {
  description = ""
  default     = ""
}

variable "docker_ucp_license_path" {
  description = ""
  default     = ""
}

variable "docker_ucp_version" {
  description = ""
  default     = ""
}

variable "dev_registry_username" {
  description = ""
  default     = ""
}

variable "dev_registry_password" {
  description = ""
  default     = ""
}

variable "use_dev_version" {
  description = ""
  default     = ""
}

variable "docker_engine_enable_remote_tcp" {
  description = "Whether the engine should allow remote TCP connections"
  default     = false
}

variable "docker_engine_ca_file" {
  description = "The path to the ca.pem file for the CA to to use to generate Docker engine's SSL certificate if remote TCP enabled"
  default     = ""
}

variable "docker_engine_ca_key_file" {
  description = "The path to the ca-key.pem file for the CA to to use to generate Docker engine's SSL certificate if remote TCP enabled"
  default     = ""
}

variable "extra_vars" {
  description = "Any additional vars to add"
  default     = ""
}

variable "docker_worker_orchestration" {
  description = ""
  default     = "swarm"
}

variable "docker_enable_fips" {
  description = "Enable FIPS in the OS (RHEL and Windows only)"
  default     = false
}
