// Outputs for network module, including IDs of network, subnets, and router

output "network_id" {
  description = "ID of the main network"
  value       = openstack_networking_network_v2.net.id
}

output "web_subnet_id" {
  description = "ID of the web tier subnet"
  value       = openstack_networking_subnet_v2.web_subnet.id
}

output "app_subnet_id" {
  description = "ID of the app tier subnet"
  value       = openstack_networking_subnet_v2.app_subnet.id
}

output "db_subnet_id" {
  description = "ID of the database tier subnet"
  value       = openstack_networking_subnet_v2.db_subnet.id
}

output "router_id" {
  description = "ID of the router"
  value       = openstack_networking_router_v2.router.id
}
