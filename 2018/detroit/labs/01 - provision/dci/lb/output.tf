output "pool_id" {
  value = "${join("",azurerm_lb_backend_address_pool.pool.*.id)}"
}

output "probe_id" {
  value = "${join("",azurerm_lb_probe.lb_probe.*.id)}"
}

output "lb_id" {
  value = "${join("",azurerm_lb.lb.*.id)}"
}

output "fqdn" {
  value = "${join("",azurerm_public_ip.pub_ip.*.fqdn)}"
}
