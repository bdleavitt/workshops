# Docker EE Cluster Topology
####################################
linux_ucp_manager_count  = 3
linux_ucp_worker_count   = 2
linux_dtr_count          = 3
windows_ucp_worker_count = 2

deployment               = "docker-ee"                   # VM/Hostname prefix string. Prepended to all resources.

# Docker EE Configuration
###################################
ansible_inventory        = "./inventory/1.hosts"

# Docker EE Engine Version
###################################
docker_ee_release_channel = "stable"
docker_ee_version         = "18.09"
docker_ee_package_version = "latest"
docker_ee_subscriptions_ubuntu = "sub-00000000-0000-0000-0000-000000000000"

# Docker UCP Version and Configuration
###################################
docker_ucp_version        = "3.1.0"
# docker_ucp_license_path   = "./docker_subscription.lic"
# docker_ucp_cert_file      = "./ssl_cert/ucp_cert.pem"
# docker_ucp_ca_file        = "./ssl_cert/ucp_ca.pem"
# docker_ucp_key_file       = "./ssl_cert/ucp_key.pem"
docker_ucp_admin_username = "admin"
docker_ucp_admin_password = "DockerEE123!"
# docker_ucp_lb             = "<placeholder>"

# Docker DTR Version and Configuration
###################################
docker_dtr_version        = "2.6.0"
# docker_dtr_cert_file      = "./ssl_cert/dtr_cert.pem"
# docker_dtr_key_file       = "./ssl_cert/dtr_key.pem"
# docker_dtr_ca_file        = "./ssl_cert/dtr_ca.pem"
# docker_dtr_lb             = "<placeholder>"

# Azure Credentials
###################################
region                   = "eastus"                    # Where to deploy (e.g. Central US)

# Only set variable for the SSH key
ssh_private_key_path     = "./ssh/id_rsa"               # Path to your ssh private key (stubbed in for workshop)

client_id       = "00000000-0000-0000-0000-000000000000" # Client ID
client_secret   = "0000000000000000000000000000000000000000000="    # Client Secret
subscription_id = "00000000-0000-0000-0000-000000000000" # Subscription UUID
tenant_id       = "00000000-0000-0000-0000-000000000000" # Tenant UUID

# Kubernetes Options (only enable when deploying Docker EE 2.0 with UCP 3.0.2 or higher)
#####################################
enable_kubernetes_azure_disk = true # Set to true to enable Persistent Volumes for Kubernetes
enable_kubernetes_azure_load_balancer = true # Set to true to enable Load Balancer integration for Kubernetes

# Azure SKUs for Docker EE
####################################
## Linux manager image
linux_manager = {
  publisher = "Canonical"    # OS VHD publisher
  offer     = "UbuntuServer" # OS VHD offer
  sku       = "18.04-LTS"    # OS VHD SKU
  version   = "latest"       # OS VHD version
}

## Linux worker image
linux_worker = {
  publisher = "Canonical"    # OS VHD publisher
  offer     = "UbuntuServer" # OS VHD offer
  sku       = "18.04-LTS"    # OS VHD SKU
  version   = "latest"       # OS VHD version
}

## Windows worker image
#windows_worker = {
  publisher = "MicrosoftWindowsServer" # OS VHD publisher
  offer     = "WindowsServer"          # OS VHD offer
  sku       = "2016-DataCenter"        # OS VHD SKU
  version   = "latest"                 # OS VHD version
}

# VM Credentials and Domains
####################################
linux_user = "dockeradmin"
windows_user              = "dockeradmin"
windows_admin_password    = "DockerEE123!"

# Docker EE VM Settings
####################################
#linux_manager_os_disk_type  = "Premium_LRS"
#linux_manager_os_disk_cache = "None"
#manager_data_disk_size      = "10"
#manager_data_disk_cache     = "None"
#
#linux_worker_os_disk_typei   = "Premium_LRS"
#linux_worker_os_disk_cache   = "None"
#linux_worker_data_disk_size  = "10"
#linux_worker_data_disk_cache = "None"
#
#windows_worker_os_disk_type    = "Premium_LRS"
#windows_worker_os_disk_cache   = "None"
#windows_worker_data_disk_size  = "10"
#windows_worker_data_disk_cache = "None"

# Docker EE Uninstallation
####################################
#linux_ucp_uninstall_command   =""
#windows_ucp_uninstall_command =""
#linux_dtr_uninstall_command   =""

# Load balancer DNS names
####################################
#docker_ucp_lb             = "ucp.example.com"
#docker_dtr_lb             = "dtr.example.com"

# Azure Configuration Options
####################################
#vnet_addr_space           = ["172.31.0.0/24"]
#subnet_prefix             = "172.31.0.0/24"

# OPTIONAL: Database VM
####################################
#linux_database_count      = 0
#windows_database_count    = 0

# OPTIONAL: Build VM
####################################
#linux_build_server_count   = 0
#windows_build_server_count = 0
