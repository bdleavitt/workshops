output "this_inventory" {
  description = "The content of the Ansible hosts file"
  value       = "${module.inventory.hosts_content}"
}
