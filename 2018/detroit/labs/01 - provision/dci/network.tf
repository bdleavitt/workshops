# create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = "${var.vnet_addr_space}"
}

# create subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "${var.subnet_prefix}"
}

resource "azurerm_public_ip" "linux_ucp_manager" {
  count                        = "${var.linux_ucp_manager_count}"
  name                         = "${format("%s-Manager-PublicIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "linux_ucp_manager" {
  count                     = "${var.linux_ucp_manager_count}"
  name                      = "${format("%s-Manager-LinuxNet-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.ee_sg.id}"

  ip_configuration {
    name                                    = "${format("%s-Manager-LinuxIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    load_balancer_backend_address_pools_ids = ["${compact(list(module.ucp_app_lb.pool_id))}"]
    private_ip_address_allocation           = "dynamic"
    public_ip_address_id                    = "${element(azurerm_public_ip.linux_ucp_manager.*.id, count.index)}"
  }
}

resource "azurerm_public_ip" "linux_ucp_worker" {
  count                        = "${var.linux_ucp_worker_count}"
  name                         = "${format("%s-Worker-PublicIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "linux_ucp_worker" {
  count                     = "${var.linux_ucp_worker_count}"
  name                      = "${format("%s-Worker-LinuxNet-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.linux_sg.id}"

  ip_configuration {
    name                                    = "${format("%s-Worker-LinuxIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    load_balancer_backend_address_pools_ids = ["${compact(list(module.lin_app_lb.pool_id))}"]
    private_ip_address_allocation           = "dynamic"
    public_ip_address_id                    = "${element(azurerm_public_ip.linux_ucp_worker.*.id, count.index)}"
  }
}

resource "azurerm_public_ip" "windows_ucp_worker" {
  count                        = "${var.windows_ucp_worker_count}"
  name                         = "${format("%s-Windows-PublicIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "windows_ucp_worker" {
  count                     = "${var.windows_ucp_worker_count}"
  name                      = "${format("%s-Worker-WindowsNet-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.windows_sg.id}"

  ip_configuration {
    name                                    = "${format("%s-Worker-WindowsIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    load_balancer_backend_address_pools_ids = ["${compact(list(module.win_app_lb.pool_id))}"]
    private_ip_address_allocation           = "dynamic"
    public_ip_address_id                    = "${element(azurerm_public_ip.windows_ucp_worker.*.id, count.index)}"
  }
}

resource "azurerm_public_ip" "linux_dtr" {
  count                        = "${var.linux_dtr_count}"
  name                         = "${format("%s-DTR-PublicIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "linux_dtr" {
  count                     = "${var.linux_dtr_count}"
  name                      = "${format("%s-DTR-LinuxNet-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.ee_sg.id}"

  ip_configuration {
    name                                    = "${format("%s-DTR-LinuxIP-%s", azurerm_resource_group.rg.name, "${count.index + 1}")}"
    subnet_id                               = "${azurerm_subnet.subnet.id}"
    load_balancer_backend_address_pools_ids = ["${compact(list(module.dtr_app_lb.pool_id))}"]
    private_ip_address_allocation           = "dynamic"
    public_ip_address_id                    = "${element(azurerm_public_ip.linux_dtr.*.id, count.index)}"
  }
}
