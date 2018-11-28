# Split Primary and Replicas
locals {
  linux_ucp_manager_primary_name = "${element(var.linux_ucp_manager_names, 0)}" # Primary manager
  linux_ucp_manager_primary_ip   = "${element(var.linux_ucp_manager_ips, 0)}"   # Primary manager

  linux_ucp_manager_replica_names = "${slice(var.linux_ucp_manager_names, 1, length(var.linux_ucp_manager_names))}"
  linux_ucp_manager_replica_ips   = "${slice(var.linux_ucp_manager_ips, 1, length(var.linux_ucp_manager_ips))}"

  # Split DTR nodes into primary + replica sublists.  Ensure a split on an empty list returns an empty list instead of failing
  linux_dtr_worker_primary_name = "${slice(var.linux_dtr_worker_names, 0, length(var.linux_dtr_worker_names) > 0 ? 1 : 0)}" # Linux is always primary DTR
  linux_dtr_worker_primary_ip   = "${slice(var.linux_dtr_worker_ips, 0, length(var.linux_dtr_worker_ips) > 0 ? 1 : 0)}"

  linux_dtr_worker_replica_names = "${slice(var.linux_dtr_worker_names, length(var.linux_dtr_worker_names) > 0 ? 1 : 0, length(var.linux_dtr_worker_names))}" # Linux DTR replica
  linux_dtr_worker_replica_ips   = "${slice(var.linux_dtr_worker_ips, length(var.linux_dtr_worker_ips) > 0 ? 1 : 0, length(var.linux_dtr_worker_ips))}"       # Linux DTR replica

  load_balancers = "${var.docker_ucp_lb == "" ? "#" : ""}docker_ucp_lb=${var.docker_ucp_lb}\n${var.docker_dtr_lb == "" ? "#" : ""}docker_dtr_lb=${var.docker_dtr_lb}"
}

# Template for ansible inventory
data "template_file" "inventory" {
  template = "${file("${path.module}/inventory.tpl")}"

  vars {
    private_key_file = "${var.private_key_file}"

    linux_manager_primary  = "${format("%s ansible_user=%s ansible_host=%s", local.linux_ucp_manager_primary_name, var.linux_user, local.linux_ucp_manager_primary_ip)}"
    linux_manager_replicas = "${join("\n", formatlist("%s ansible_user=%s ansible_host=%s", local.linux_ucp_manager_replica_names, var.linux_user, local.linux_ucp_manager_replica_ips))}"
    linux_dtr_primary      = "${join("\n", formatlist("%s ansible_user=%s ansible_host=%s", local.linux_dtr_worker_primary_name, var.linux_user, local.linux_dtr_worker_primary_ip))}"
    linux_dtr_replicas     = "${join("\n", formatlist("%s ansible_user=%s ansible_host=%s", local.linux_dtr_worker_replica_names, var.linux_user, local.linux_dtr_worker_replica_ips))}"
    linux_workers          = "${length(var.linux_worker_names) > 0 ? join("\n", formatlist("%s ansible_user=%s ansible_host=%s", var.linux_worker_names, var.linux_user, var.linux_worker_ips)) : ""}"

    windows_workers = "${length(var.windows_worker_names) > 0
				 ? join("\n", formatlist("%s ansible_host=%s ansible_user=${var.windows_user} ansible_password='%s'", var.windows_worker_names, var.windows_worker_ips, var.windows_worker_passwords))
				 : ""}"

    linux_ucp_lbs = "${length(var.linux_ucp_lb_names) > 0 ? join("\n", formatlist("%s ansible_user=%s ansible_host=%s", var.linux_ucp_lb_names, var.linux_user, var.linux_ucp_lb_ips)) : ""}"
    linux_dtr_lbs = "${length(var.linux_dtr_lb_names) > 0 ? join("\n", formatlist("%s ansible_user=%s ansible_host=%s", var.linux_dtr_lb_names, var.linux_user, var.linux_dtr_lb_ips)) : ""}"

    # extra configs
    linux_databases   = "${length(var.linux_database_names) > 0 ? join("\n", formatlist("%s ansible_user=%s ansible_host=%s", var.linux_database_names, var.linux_user, var.linux_database_ips)) : ""}"
    linux_build       = "${length(var.linux_build_server_names) > 0 ? join("\n", formatlist("%s ansible_user=%s ansible_host=%s", var.linux_build_server_names, var.linux_user, var.linux_build_server_ips)) : ""}"
    windows_databases = "${length(var.windows_database_names) > 0 ? join("\n", formatlist("%s ansible_host=%s", var.windows_database_names, var.windows_database_ips)) : ""}"
    windows_build     = "${length(var.windows_build_server_names) > 0 ? join("\n", formatlist("%s ansible_host=%s", var.windows_build_server_names, var.windows_build_server_ips)) : ""}"
    infra_stack       = "${var.infra_stack}"
    load_balancers    = "${local.load_balancers}"
    extra_vars        = "${var.extra_vars}"

    cloudstor_plugin_version        = "${var.cloudstor_plugin_version == "" ? "#" : ""}cloudstor_plugin_version=${var.cloudstor_plugin_version}"
    docker_dtr_ca_file              = "${var.docker_dtr_ca_file == "" ? "#" : ""}docker_dtr_ca_file=${var.docker_dtr_ca_file}"
    docker_dtr_cert_file            = "${var.docker_dtr_cert_file == "" ? "#" : ""}docker_dtr_cert_file=${var.docker_dtr_cert_file}"
    docker_dtr_key_file             = "${var.docker_dtr_key_file == "" ? "#" : ""}docker_dtr_key_file=${var.docker_dtr_key_file}"
    docker_dtr_replica_id           = "${var.docker_dtr_replica_id == "" ? "#" : ""}docker_dtr_replica_id=${var.docker_dtr_replica_id}"
    docker_dtr_version              = "${var.docker_dtr_version == "" ? "#" : ""}docker_dtr_version=${var.docker_dtr_version}"
    docker_dtr_image_repository     = "${var.docker_dtr_image_repository == "" ? "#" : ""}docker_dtr_image_repository=${var.docker_dtr_image_repository}"
    docker_dtr_install_args         = "${var.docker_dtr_install_args == "" ? "#" : ""}docker_dtr_install_args=${var.docker_dtr_install_args}"
    docker_ee_package_version       = "${var.docker_ee_package_version == "" ? "#" : ""}docker_ee_package_version=${var.docker_ee_package_version}"
    docker_ee_package_version_win   = "${var.docker_ee_package_version_win == "" ? "#" : ""}docker_ee_package_version_win=${var.docker_ee_package_version_win}"
    docker_ee_release_channel       = "${var.docker_ee_release_channel == "" ? "#" : ""}docker_ee_release_channel=${var.docker_ee_release_channel}"
    docker_ee_repo                  = "${var.docker_ee_repo == "" ? "#" : ""}docker_ee_repo=${var.docker_ee_repo}"
    docker_ee_repository_url        = "${var.docker_ee_repository_url == "" ? "#" : ""}docker_ee_repository_url=${var.docker_ee_repository_url}"
    docker_ee_package_url_win       = "${var.docker_ee_package_url_win == "" ? "#" : ""}docker_ee_package_url_win=${var.docker_ee_package_url_win}"
    docker_ee_subscriptions_centos  = "${var.docker_ee_subscriptions_centos == "" ? "#" : ""}docker_ee_subscriptions_centos=${var.docker_ee_subscriptions_centos}"
    docker_ee_subscriptions_oracle  = "${var.docker_ee_subscriptions_oracle == "" ? "#" : ""}docker_ee_subscriptions_oracle=${var.docker_ee_subscriptions_oracle}"
    docker_ee_subscriptions_redhat  = "${var.docker_ee_subscriptions_redhat == "" ? "#" : ""}docker_ee_subscriptions_redhat=${var.docker_ee_subscriptions_redhat}"
    docker_ee_subscriptions_sles    = "${var.docker_ee_subscriptions_sles == "" ? "#" : ""}docker_ee_subscriptions_sles=${var.docker_ee_subscriptions_sles}"
    docker_ee_subscriptions_ubuntu  = "${var.docker_ee_subscriptions_ubuntu == "" ? "#" : ""}docker_ee_subscriptions_ubuntu=${var.docker_ee_subscriptions_ubuntu}"
    docker_ee_version               = "${var.docker_ee_version == "" ? "#" : ""}docker_ee_version=${var.docker_ee_version}"
    docker_hub_id                   = "${var.docker_hub_id == "" ? "#" : ""}docker_hub_id=${var.docker_hub_id}"
    docker_hub_password             = "${var.docker_hub_password == "" ? "#" : ""}docker_hub_password=${var.docker_hub_password}"
    docker_storage_driver           = "${var.docker_storage_driver == "" ? "#" : ""}docker_storage_driver=${var.docker_storage_driver}"
    docker_storage_fstype           = "${var.docker_storage_fstype == "" ? "#" : ""}docker_storage_fstype=${var.docker_storage_fstype}"
    docker_storage_volume           = "${var.docker_storage_volume == "" ? "#" : ""}docker_storage_volume=${var.docker_storage_volume}"
    docker_swarm_listen_address     = "${var.docker_swarm_listen_address == "" ? "#" : ""}docker_swarm_listen_address=${var.docker_swarm_listen_address}"
    docker_ucp_admin_password       = "${var.docker_ucp_admin_password == "" ? "#" : ""}docker_ucp_admin_password=${var.docker_ucp_admin_password}"
    docker_ucp_admin_username       = "${var.docker_ucp_admin_username == "" ? "#" : ""}docker_ucp_admin_username=${var.docker_ucp_admin_username}"
    docker_ucp_ca_file              = "${var.docker_ucp_ca_file == "" ? "#" : ""}docker_ucp_ca_file=${var.docker_ucp_ca_file}"
    docker_ucp_cert_file            = "${var.docker_ucp_cert_file == "" ? "#" : ""}docker_ucp_cert_file=${var.docker_ucp_cert_file}"
    docker_ucp_key_file             = "${var.docker_ucp_key_file == "" ? "#" : ""}docker_ucp_key_file=${var.docker_ucp_key_file}"
    docker_ucp_image_repository     = "${var.docker_ucp_image_repository == "" ? "#" : ""}docker_ucp_image_repository=${var.docker_ucp_image_repository}"
    docker_ucp_install_args         = "${var.docker_ucp_install_args == "" ? "#" : ""}docker_ucp_install_args=${var.docker_ucp_install_args}"
    docker_ucp_license_path         = "${var.docker_ucp_license_path == "" ? "#" : ""}docker_ucp_license_path=${var.docker_ucp_license_path}"
    docker_ucp_version              = "${var.docker_ucp_version == "" ? "#" : ""}docker_ucp_version=${var.docker_ucp_version}"
    dev_registry_username           = "${var.dev_registry_username == "" ? "#" : ""}dev_registry_username=${var.dev_registry_username}"
    dev_registry_password           = "${var.dev_registry_password == "" ? "#" : ""}dev_registry_password=${var.dev_registry_password}"
    use_dev_version                 = "${var.use_dev_version == "" ? "#" : ""}use_dev_version=${var.use_dev_version}"
    docker_engine_enable_remote_tcp = "${var.docker_engine_enable_remote_tcp == "" ? "#" : ""}docker_engine_enable_remote_tcp=${var.docker_engine_enable_remote_tcp}"
    docker_engine_ca_file           = "${var.docker_engine_ca_file == "" ? "#" : ""}docker_engine_ca_file=${var.docker_engine_ca_file}"
    docker_engine_ca_key_file       = "${var.docker_engine_ca_key_file == "" ? "#" : ""}docker_engine_ca_key_file=${var.docker_engine_ca_key_file}"
    docker_worker_orchestration     = "${var.docker_worker_orchestration == "" ? "swarm" : ""}docker_worker_orchestration=${var.docker_worker_orchestration}"
  }
}

resource "local_file" "ansible_inventory" {
  content  = "${data.template_file.inventory.rendered}"
  filename = "${var.inventory_file}"
}
