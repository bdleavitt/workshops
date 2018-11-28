output "app_lb_id" {
  value = "${module.win_app_lb.pool_id}"
}

output "windows_password" {
  value = "${local.windows_password}"
}
