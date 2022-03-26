output "server_name_list" {
  value = join(",", ncloud_server.server.*.name)
}

output "lb_name_list" {
    value = ncloud_load_balancer.lb.name
}