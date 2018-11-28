# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "deployment" {
  description = "The deployment name for this stack"
}

variable "region" {
  description = "Location/Region of resources deployed"
  default     = ""
}

variable "windows_user" {
  description = "The account to use for WinRM connections"
  default     = "Administrator"
}

variable "linux_user" {
  description = "The account to use for ssh connections"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key file"
}

variable "windows_admin_password" {
  description = "Windows worker password"
  default     = ""
}

resource "random_string" "windows_password" {
  length  = 16
  special = false

  keepers = {
    # Generate a new password only when a new deployment is defined
    deployment = "${var.deployment}"
  }
}

# 1. generate a random string
# 2. append a known string of mT4! which will satisfy 4 of the password complexity requirements:
#    i.   Contains an uppercase character
#    ii.  Contains a lowercase character
#    iii. Contains a numeric digit
#    iv.  Contains a special character
locals {
  windows_password = "${var.windows_admin_password == "" ? "${random_string.windows_password.result}mT4!" : var.windows_admin_password}"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

#######################
# UCP
#######################
## Manager details
variable "linux_manager_instance_type" {
  description = "The instance type for the managers"
  default     = ""
}

variable "linux_ucp_manager_count" {
  description = "Number of Manager nodes"
  default     = 3
}

## Linux worker details
variable "linux_worker_instance_type" {
  description = "The instance type for the Linux workers"
  default     = ""
}

variable "linux_ucp_worker_count" {
  description = "Number of Linux worker nodes"
  default     = 1
}

## Windows worker details
variable "windows_worker_instance_type" {
  description = "The instance type for the Windows workers"
  default     = ""
}

variable "windows_ucp_worker_count" {
  description = "Number of Windows worker nodes"
  default     = 1
}

#######################
# DTR
#######################
variable "dtr_instance_type" {
  description = "The instance type for the dtr nodes"
  default     = ""
}

variable "linux_dtr_count" {
  description = "Number of Linux DTR nodes"
  default     = 3
}

#######################
# Database nodes
#######################

variable "linux_database_count" {
  description = "Number of Linux database VMs. These VMs have resources specified separately."
  default     = 0
}

variable "windows_database_count" {
  description = "Number of Windows database VMs. These VMs have resources specified separately."
  default     = 0
}

#######################
# Build nodes
#######################

variable "linux_build_server_count" {
  description = "Number of Linux build server VMs. These VMs have resources specified separately."
  default     = 0
}

variable "windows_build_server_count" {
  description = "Number of Windows build server VMs. These VMs have resources specified separately."
  default     = 0
}

#######################
# Load Balancers
#######################

variable "docker_ucp_lb" {
  description = "UCP load balancer DNS name"
  default     = ""
}

variable "docker_dtr_lb" {
  description = "DTR load balancer DNS name"
  default     = ""
}

#######################
# Ansible
#######################

variable "ansible_inventory" {
  description = "Ansible-compatible inventory file used to store the list of hosts"
  default     = "inventory/1.hosts"
}

variable "ucp_license_path" {
  description = "UCP License path"
  default     = ""
}

variable "ucp_admin_password" {
  description = "UCP Admin password"
  default     = ""
}

resource "random_string" "ucp_password" {
  length  = 12
  special = false

  keepers = {
    # Generate a new password only when a new deployment is defined
    deployment = "${var.deployment}"
  }
}

locals {
  ucp_admin_password = "${var.docker_ucp_admin_password == "" ? var.ucp_admin_password == "" ? "${random_string.ucp_password.result}" : var.ucp_admin_password : var.docker_ucp_admin_password}"
  ucp_admin_username = "${var.docker_ucp_admin_username == "" ? "admin" : var.docker_ucp_admin_username}"
}

variable "cloudstor_plugin_version" {
  description = "The version of cloudstor to use"
  default     = "1.0"
}

variable "docker_dtr_ca_file" {
  description = "The path to the ca.pem file for DTR's SSL certificat"
  default     = ""
}

variable "docker_dtr_cert_file" {
  description = "The path to the cert.pem file for DTR's SSL certificate"
  default     = ""
}

variable "docker_dtr_key_file" {
  description = "The path to the key.pem file for DTR's SSL Certificate"
  default     = ""
}

variable "docker_dtr_replica_id" {
  description = "DEPRECATED: This value is no longer necessary to be set"
  default     = ""
}

variable "docker_dtr_version" {
  description = "The version of DTR to install"
  default     = "latest"
}

variable "docker_dtr_image_repository" {
  description = "Override the repository to pull DTR images from"
  default     = "docker"
}

variable "docker_dtr_install_args" {
  description = "Provide additional arguments to DTR install https://docs.docker.com/reference/dtr/2.5/cli/install/"
  default     = ""
}

variable "docker_ee_package_version" {
  description = "The explicit host-specific package version to use to install Docker EE"
  default     = ""
}

variable "docker_ee_package_version_win" {
  description = "The explicit package version to use to install Docker EE on Windows"
  default     = ""
}

variable "docker_ee_release_channel" {
  description = "The channel to pull Docker EE from"
  default     = "stable"
}

variable "docker_ee_repo" {
  description = "The base URL for the Docker EE repository"
  default     = "https://storebits.docker.com/ee"
}

variable "docker_ee_repository_url" {
  description = "Explict URL for the Docker EE repository"
  default     = ""
}

variable "docker_ee_package_url_win" {
  description = "The explicit Windows package url to use to install Docker EE on Windows"
  default     = ""
}

variable "docker_ee_subscriptions_centos" {
  description = "The subscription UUID for accessing your packages: sub-xxx-xxx-xxx-xxx"
  default     = ""
}

variable "docker_ee_subscriptions_oracle" {
  description = "The subscription UUID for accessing your packages: sub-xxx-xxx-xxx-xxx"
  default     = ""
}

variable "docker_ee_subscriptions_redhat" {
  description = "The subscription UUID for accessing your packages: sub-xxx-xxx-xxx-xxx"
  default     = ""
}

variable "docker_ee_subscriptions_sles" {
  description = "The subscription UUID for accessing your packages: sub-xxx-xxx-xxx-xxx"
  default     = ""
}

variable "docker_ee_subscriptions_ubuntu" {
  description = "The subscription UUID for accessing your packages: sub-xxx-xxx-xxx-xxx"
  default     = ""
}

variable "docker_ee_version" {
  description = "The Major.Minor version to stay on a specific release"
  default     = ""
}

variable "docker_hub_id" {
  description = "Your docker hub id to fetch subscriptions and licenses"
  default     = ""
}

variable "docker_hub_password" {
  description = "Your docker hub pass to fetch subscriptions and licenses"
  default     = ""
}

variable "docker_storage_driver" {
  description = "Set this to a value volume storage driver to override storage driver (overlay2, aufs, devicemapper, btrfs)"
  default     = ""
}

variable "docker_storage_fstype" {
  description = "Set this to a value volume storage fstype to override storage fs type (xfs, ext4, btrfs)"
  default     = ""
}

variable "docker_storage_volume" {
  description = "Set this to a block device which will serve as the docker storage volume"
  default     = ""
}

variable "docker_swarm_listen_address" {
  description = "Set this to address you swarm to listen on the manager"
  default     = ""
}

variable "docker_ucp_admin_password" {
  description = "Set this to the password you want to use to access UCP"
  default     = ""
}

variable "docker_ucp_admin_username" {
  description = "Set this to the username you want to use to access UCP"
  default     = "admin"
}

variable "docker_ucp_ca_file" {
  description = "The path to the ca.pem file for UCP's SSL Configuration"
  default     = ""
}

variable "docker_ucp_cert_file" {
  description = "The path to the cert file for UCP's SSL Configuration"
  default     = ""
}

variable "docker_ucp_key_file" {
  description = "The path to the key.pem file for UCP's SSL Configuration"
  default     = ""
}

variable "docker_ucp_image_repository" {
  description = "Override the repository to pull UCP images from"
  default     = "docker"
}

variable "docker_ucp_install_args" {
  description = "Provide additional arguments to UCP install https://docs.docker.com/reference/ucp/3.0/cli/install/"
  default     = ""
}

variable "docker_ucp_license_path" {
  description = "The path to your UCP license file"
  default     = ""
}

variable "docker_ucp_version" {
  description = "The version of UCP to install"
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

variable "dev_registry_username" {
  description = "INTERNAL: docker hub id to access internal builds"
  default     = ""
}

variable "dev_registry_password" {
  description = "INTERNAL: docker hub password to access internal builds"
  default     = ""
}

variable "use_dev_version" {
  description = "INTERNAL: activate internal dev image options"
  default     = ""
}

variable "docker_worker_orchestration" {
  description = "Set worker orchestration mode to 'swarm' or 'kubernetes'"
  default     = "swarm"
}

variable "docker_enable_fips" {
  description = "Enable FIPS in the OS (RHEL and Windows only)"
  default     = false
}
