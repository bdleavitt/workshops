# create the UCP LB
module "ucp_app_lb" {
  source         = "./lb"
  rg_name        = "${azurerm_resource_group.rg.name}"
  location       = "${azurerm_resource_group.rg.location}"
  lb_fe_ip_name  = "ucp_app_ip"
  fe_ip_cfg_name = "ucp_app_fe"
  lb_name        = "ucp_app_lb"
  lb_pool_name   = "ucp_app_be_pool"
  dns_prefix     = "ucpapp"
  probe_port     = 443
  create         = "${var.enable_load_balancers ? 1 : 0}"
}

# Create a rule
resource "azurerm_lb_rule" "ucp_lb_rule" {
  count                          = "${var.enable_load_balancers ? 1 : 0}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${module.ucp_app_lb.lb_id}"
  name                           = "UCPHttpsLBRule"
  protocol                       = "tcp"
  frontend_port                  = "443"
  backend_port                   = "443"
  frontend_ip_configuration_name = "ucp_app_fe"
  enable_floating_ip             = false
  backend_address_pool_id        = "${module.ucp_app_lb.pool_id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${module.ucp_app_lb.probe_id}"
}

resource "azurerm_lb_rule" "kube_lb_rule" {
  count                          = "${var.enable_load_balancers ? 1 : 0}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${module.ucp_app_lb.lb_id}"
  name                           = "KubeHttpsLBRule"
  protocol                       = "tcp"
  frontend_port                  = "6443"
  backend_port                   = "6443"
  frontend_ip_configuration_name = "ucp_app_fe"
  enable_floating_ip             = false
  backend_address_pool_id        = "${module.ucp_app_lb.pool_id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${module.ucp_app_lb.probe_id}"
}

# create the Linux app LB
module "lin_app_lb" {
  source         = "./lb"
  rg_name        = "${azurerm_resource_group.rg.name}"
  location       = "${azurerm_resource_group.rg.location}"
  lb_fe_ip_name  = "linux_app_ip"
  fe_ip_cfg_name = "lin_app_fe"
  lb_name        = "linux_app_lb"
  lb_pool_name   = "linux_app_be_pool"
  dns_prefix     = "linapp"
  probe_port     = 22
  create         = "${var.enable_load_balancers ? var.enable_kubernetes_azure_load_balancer ? 0 : 1 : 0}"
}

resource "azurerm_lb_rule" "app_https_rule" {
  count                          = "${var.enable_load_balancers ? var.enable_kubernetes_azure_load_balancer ? 0 : 1 : 0}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${module.lin_app_lb.lb_id}"
  name                           = "AppHttpsLBRule"
  protocol                       = "tcp"
  frontend_port                  = "443"
  backend_port                   = "8443"
  frontend_ip_configuration_name = "lin_app_fe"
  enable_floating_ip             = false
  backend_address_pool_id        = "${module.lin_app_lb.pool_id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${module.lin_app_lb.probe_id}"
}

resource "azurerm_lb_rule" "app_http_rule" {
  count                          = "${var.enable_load_balancers ? var.enable_kubernetes_azure_load_balancer ? 0 : 1 : 0}"
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${module.lin_app_lb.lb_id}"
  name                           = "AppHttpLBRule"
  protocol                       = "tcp"
  frontend_port                  = "80"
  backend_port                   = "8000"
  frontend_ip_configuration_name = "lin_app_fe"
  enable_floating_ip             = false
  backend_address_pool_id        = "${module.lin_app_lb.pool_id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${module.lin_app_lb.probe_id}"
}

# create the Windows app LB
module "win_app_lb" {
  source         = "./lb"
  rg_name        = "${azurerm_resource_group.rg.name}"
  location       = "${azurerm_resource_group.rg.location}"
  lb_fe_ip_name  = "windows_app_ip"
  fe_ip_cfg_name = "win_app_fe"
  lb_name        = "windows_app_lb"
  lb_pool_name   = "windows_app_be_pool"
  dns_prefix     = "winapp"
  probe_port     = 3389
  create         = "${var.enable_load_balancers ? var.enable_kubernetes_azure_load_balancer ? 0 : 1 : 0}"
}

# create the DTR app LB
module "dtr_app_lb" {
  source         = "./lb"
  rg_name        = "${azurerm_resource_group.rg.name}"
  location       = "${azurerm_resource_group.rg.location}"
  lb_fe_ip_name  = "dtr_app_ip"
  fe_ip_cfg_name = "dtr_app_fe"
  lb_name        = "dtr_app_lb"
  lb_pool_name   = "dtr_app_be_pool"
  dns_prefix     = "dtrapp"
  probe_port     = 443
  create         = "${var.enable_load_balancers ? var.linux_dtr_count > 0 ? 1 : 0 : 0}"
}

resource "azurerm_lb_rule" "dtr_https_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${module.dtr_app_lb.lb_id}"
  name                           = "DTRHttpsLBRule"
  protocol                       = "tcp"
  frontend_port                  = "443"
  backend_port                   = "443"
  frontend_ip_configuration_name = "dtr_app_fe"
  enable_floating_ip             = false
  backend_address_pool_id        = "${module.dtr_app_lb.pool_id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${module.dtr_app_lb.probe_id}"
  count                          = "${var.enable_load_balancers ? var.linux_dtr_count > 0 ? 1 : 0 : 0}"
}

resource "azurerm_lb_rule" "dtr_http_rule" {
  resource_group_name            = "${azurerm_resource_group.rg.name}"
  loadbalancer_id                = "${module.dtr_app_lb.lb_id}"
  name                           = "DTRHttpLBRule"
  protocol                       = "tcp"
  frontend_port                  = "80"
  backend_port                   = "80"
  frontend_ip_configuration_name = "dtr_app_fe"
  enable_floating_ip             = false
  backend_address_pool_id        = "${module.dtr_app_lb.pool_id}"
  idle_timeout_in_minutes        = 5
  probe_id                       = "${module.dtr_app_lb.probe_id}"
  count                          = "${var.enable_load_balancers ? var.linux_dtr_count > 0 ? 1 : 0 : 0}"
}
