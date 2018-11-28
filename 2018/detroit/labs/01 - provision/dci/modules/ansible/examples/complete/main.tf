data "template_file" "opts" {
  template = <<EOF
region=$${region}
EOF

  vars {
    region = "us-west"
  }
}

variable "windows_worker_passwords" {
  default = [
    "$$a",
    "$$b$$",
    "$$$$c$$$$",
  ]
}

data "template_file" "windows_worker_passwords" {
  count    = 3
  template = "${replace(var.windows_worker_passwords[count.index], "$", "$$$$")}"
}

module "inventory" {
  source = "./modules/ansible"

  inventory_file = "1.hosts"

  linux_user               = "docker"
  windows_user             = "admin"
  windows_worker_passwords = "${data.template_file.windows_worker_passwords.*.rendered}"

  linux_ucp_manager_names = ["lmgr1", "lmgr2", "lmgr3"]
  linux_ucp_manager_ips   = ["10.0.0.1", "10.0.0.2", "10.0.0.3"]

  linux_dtr_worker_names = ["ldtr1", "ldtr2", "ldtr3"]
  linux_dtr_worker_ips   = ["10.0.1.1", "10.0.1.2", "10.0.1.3"]

  linux_worker_names = ["lwkr1", "lwkr2", "lwkr3"]
  linux_worker_ips   = ["10.0.2.1", "10.0.2.2", "10.0.2.3"]

  windows_worker_names = ["wwkr1", "wwkr2", "wwkr3"]
  windows_worker_ips   = ["10.0.2.4", "10.0.2.5", "10.0.2.6"]

  infra_stack = "null_stack"
  extra_vars  = "${data.template_file.opts.rendered}"
}
