# Produce an inventory that can be read by ansible

locals {
  # Enable Kubernetes Cloud Provider if
  # - Azure Disk is enabled or
  # - Azure Load Balancer is enabled or
  # - Docker UCP Version is latest or
  # - Docker UCP Version is 3.1, 3.2, etc
  enable_kubernetes_cloud_provider = "${var.enable_kubernetes_azure_disk || var.enable_kubernetes_azure_load_balancer || var.enable_kubernetes_cloud_provider || element(split(".", replace(var.docker_ucp_version, "-", ".")), 0) == "latest" || ( element(split(".", replace(var.docker_ucp_version, "-", ".")), 0) == "3" && element(split(".", replace(var.docker_ucp_version, "-", ".")), 1) == "1" ) ? true : false}"

  # UCP 3.1 ships with k8s 1.11.1
  # Older than UCP 3.1 ships with 1.8.11
  kubernetes_orchestrator = "${element(split(".", replace(var.docker_ucp_version, "-", ".")), 0) == "latest" || ( element(split(".", replace(var.docker_ucp_version, "-", ".")), 0) == "3" && element(split(".", replace(var.docker_ucp_version, "-", ".")), 1) == "1" ) ? "1.11.1" : "1.8.11"}"
}

data "azurerm_storage_account" "dtr_storage_account" {
  name                = "${join(" ",azurerm_storage_account.dtr_storage.*.name)}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = "${var.linux_dtr_count > 0 ? 1 : 0}"
}

# Get Cloudstor's storage account name and key
data "azurerm_storage_account" "cloudstor_storage_account" {
  name                = "${azurerm_storage_account.cloudstor_storage.name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

# Get Storage Account for Kubernetes
data "azurerm_storage_account" "kube_storage_account" {
  name                = "${join(" ",azurerm_storage_account.kube_storage.*.name)}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  count               = "${var.enable_kubernetes_azure_disk || var.enable_kubernetes_azure_file ? 1 : 0}"
}

# Pass additional options
data "template_file" "extra_opts" {
  template = <<EOF
azure_dtr_storage_account=$${dtr_storage_account}
azure_dtr_storage_key=$${dtr_storage_key}
azure_app_id=$${azure_app_id}
azure_app_secret=$${azure_app_secret}
azure_tenant_id=$${azure_tenant_id}
azure_subscription_id=$${azure_subscription_id}
cloudstor_plugin_options="CLOUD_PLATFORM=AZURE AZURE_STORAGE_ACCOUNT_KEY=$${cloudstor_key} AZURE_STORAGE_ACCOUNT=$${cloudstor_account} AZURE_STORAGE_ENDPOINT=$${cloudstor_endpoint}"
ucp_pod_cidr="$${ucp_pod_cidr}"
azure_nic_ips_count=$${azure_nic_ips_count}
enable_kubernetes_cloud_provider=$${kubernetes_cloud_provider}
enable_kubernetes_azure_file=$${kubernetes_azure_file}
enable_kubernetes_azure_disk=$${kubernetes_azure_disk}
enable_kubernetes_azure_load_balancer=$${kubernetes_azure_load_balancer}
enable_kubernetes_nfs_storage=$${kubernetes_azure_nfs}
kubernetes_storage_account=$${kube_storage_account}
kubernetes_storage_key=$${kube_storage_key}
kubernetes_azure_json='{ "cloud":"AzurePublicCloud", "tenantId": "$${azure_tenant_id}", "subscriptionId": "$${azure_subscription_id}", "aadClientId": "$${azure_app_id}", "aadClientSecret": "$${azure_app_secret}", "resourceGroup": "$${azure_resource_group}", "location": "$${azure_location}", "subnetName": "$${azure_subnet_name}", "securityGroupName": "$${azure_sg_name}", "vnetName": "$${azure_vnet_name}", "vnetResourceGroup": "$${azure_vnet_rg_name}", "routeTableName": "", "primaryAvailabilitySetName": "$${azure_av_set_name}", "cloudProviderBackoff": false, "cloudProviderBackoffRetries": 0, "cloudProviderBackoffExponent": 0, "cloudProviderBackoffDuration": 0, "cloudProviderBackoffJitter": 0, "cloudProviderRatelimit": false, "cloudProviderRateLimitQPS": 0, "cloudProviderRateLimitBucket": 0, "useManagedIdentityExtension": false, "useInstanceMetadata": true }'

docker_storage_volume="/dev/disk/azure/scsi1/lun0"
docker_enable_fips=$${enable_fips}
EOF

  vars {
    dtr_storage_key                = "${join("",data.azurerm_storage_account.dtr_storage_account.*.primary_access_key)}"
    dtr_storage_account            = "${join("",data.azurerm_storage_account.dtr_storage_account.*.name)}"
    kube_storage_key               = "${join("",data.azurerm_storage_account.kube_storage_account.*.primary_access_key)}"
    kube_storage_account           = "${join("",data.azurerm_storage_account.kube_storage_account.*.name)}"
    ucp_pod_cidr                   = "${local.enable_kubernetes_cloud_provider ? var.kubernetes_pod_cidr : ""}"
    azure_app_id                   = "${var.client_id}"
    azure_app_secret               = "${var.client_secret}"
    azure_tenant_id                = "${var.tenant_id}"
    azure_subscription_id          = "${var.subscription_id}"
    azure_resource_group           = "${azurerm_resource_group.rg.name}"
    azure_location                 = "${lower(replace(var.region, " ", ""))}"
    azure_subnet_name              = "${azurerm_subnet.subnet.name}"
    azure_sg_name                  = "${azurerm_network_security_group.linux_sg.name}"
    azure_vnet_name                = "${azurerm_virtual_network.vnet.name}"
    azure_vnet_rg_name             = "${azurerm_virtual_network.vnet.resource_group_name}"
    azure_nic_ips_count            = "${var.azure_nic_ips_count}"
    azure_av_set_name              = "${azurerm_availability_set.ucp_workers.name}"
    cloudstor_key                  = "${data.azurerm_storage_account.cloudstor_storage_account.primary_access_key}"
    cloudstor_account              = "${data.azurerm_storage_account.cloudstor_storage_account.name}"
    cloudstor_endpoint             = "core.windows.net"
    kubernetes_cloud_provider      = "${local.enable_kubernetes_cloud_provider ? "True" : "False"}"
    kubernetes_azure_file          = "${var.enable_kubernetes_azure_file ? "True" : "False"}"
    kubernetes_azure_disk          = "${var.enable_kubernetes_azure_disk ? "True" : "False"}"
    kubernetes_azure_load_balancer = "${var.enable_kubernetes_azure_load_balancer ? "True" : "False"}"
    kubernetes_azure_nfs           = "${var.enable_kubernetes_nfs_storage ? "True" : "False" }"
    enable_fips                    = "${var.docker_enable_fips ? "True" : "False" }"
  }
}

# All Windows machines have the same password
# Escape any '$' characters which appear in the password to '$$'
# "$$$$" reduces to "$$" thanks to interpolation syntax
#
data "template_file" "windows_worker_passwords" {
  count    = "${var.windows_ucp_worker_count}"
  template = "${replace(local.windows_password, "$", "$$$$")}"
}

module "inventory" {
  # Would love to use a variable for the path... but Terrraform doesn't allow
  # https://github.com/hashicorp/terraform/issues/1439
  source = "./modules/ansible"

  inventory_file   = "${var.ansible_inventory}"
  private_key_file = "${var.ssh_private_key_path}"

  linux_user               = "${var.linux_user}"
  windows_user             = "${var.windows_user}"
  windows_worker_passwords = "${data.template_file.windows_worker_passwords.*.rendered}"

  linux_ucp_manager_names = "${azurerm_virtual_machine.linux_ucp_manager.*.name}"
  linux_ucp_manager_ips   = "${azurerm_public_ip.linux_ucp_manager.*.ip_address}"

  linux_dtr_worker_names = "${azurerm_virtual_machine.linux_dtr.*.name}"
  linux_dtr_worker_ips   = "${azurerm_public_ip.linux_dtr.*.ip_address}"

  linux_worker_names = "${azurerm_virtual_machine.linux_ucp_worker.*.name}"
  linux_worker_ips   = "${azurerm_public_ip.linux_ucp_worker.*.ip_address}"

  windows_worker_names = "${azurerm_virtual_machine.windows_ucp_worker.*.name}"
  windows_worker_ips   = "${azurerm_public_ip.windows_ucp_worker.*.ip_address}"

  infra_stack = "azure"
  extra_vars  = "${data.template_file.extra_opts.rendered}"

  docker_ucp_lb                  = "${var.docker_ucp_lb == "" ? module.ucp_app_lb.fqdn : var.docker_ucp_lb}"
  docker_dtr_lb                  = "${var.docker_dtr_lb == "" ? module.dtr_app_lb.fqdn : var.docker_dtr_lb}"
  cloudstor_plugin_version       = "${var.cloudstor_plugin_version}"
  docker_dtr_ca_file             = "${var.docker_dtr_ca_file}"
  docker_dtr_cert_file           = "${var.docker_dtr_cert_file}"
  docker_dtr_key_file            = "${var.docker_dtr_key_file}"
  docker_dtr_replica_id          = "${var.docker_dtr_replica_id}"
  docker_dtr_version             = "${var.docker_dtr_version}"
  docker_dtr_image_repository    = "${var.docker_dtr_image_repository}"
  docker_dtr_install_args        = "${var.docker_dtr_install_args}"
  docker_ee_package_version      = "${var.docker_ee_package_version}"
  docker_ee_package_version_win  = "${var.docker_ee_package_version_win}"
  docker_ee_release_channel      = "${var.docker_ee_release_channel}"
  docker_ee_repo                 = "${var.docker_ee_repo}"
  docker_ee_repository_url       = "${var.docker_ee_repository_url}"
  docker_ee_package_url_win      = "${var.docker_ee_package_url_win}"
  docker_ee_subscriptions_centos = "${var.docker_ee_subscriptions_centos}"
  docker_ee_subscriptions_oracle = "${var.docker_ee_subscriptions_oracle}"
  docker_ee_subscriptions_redhat = "${var.docker_ee_subscriptions_redhat}"
  docker_ee_subscriptions_sles   = "${var.docker_ee_subscriptions_sles}"
  docker_ee_subscriptions_ubuntu = "${var.docker_ee_subscriptions_ubuntu}"
  docker_ee_version              = "${var.docker_ee_version}"
  docker_hub_id                  = "${var.docker_hub_id}"
  docker_hub_password            = "${var.docker_hub_password}"
  docker_storage_driver          = "${var.docker_storage_driver}"
  docker_storage_fstype          = "${var.docker_storage_fstype}"
  docker_storage_volume          = "${var.docker_storage_volume}"
  docker_swarm_listen_address    = "${var.docker_swarm_listen_address}"
  docker_ucp_admin_password      = "${local.ucp_admin_password}"
  docker_ucp_admin_username      = "${local.ucp_admin_username}"
  docker_ucp_ca_file             = "${var.docker_ucp_ca_file}"
  docker_ucp_cert_file           = "${var.docker_ucp_cert_file}"
  docker_ucp_key_file            = "${var.docker_ucp_key_file}"
  docker_ucp_image_repository    = "${var.docker_ucp_image_repository}"
  docker_ucp_install_args        = "${var.docker_ucp_install_args}"
  docker_ucp_license_path        = "${var.docker_ucp_license_path}"
  docker_ucp_version             = "${var.docker_ucp_version}"
  dev_registry_username          = "${var.dev_registry_username}"
  dev_registry_password          = "${var.dev_registry_password}"
  use_dev_version                = "${var.use_dev_version}"
}
