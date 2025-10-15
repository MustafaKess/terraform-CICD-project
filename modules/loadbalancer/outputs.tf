// Outputs for load balancer module, including IDs and endpoints

output "lb_id" {
  description = "ID of the load balancer"
  value       = openstack_lb_loadbalancer_v2.lb.id
}

output "lb_name" {
  description = "Name of the load balancer"
  value       = openstack_lb_loadbalancer_v2.lb.name
}

output "lb_vip_address" {
  description = "VIP address of the load balancer"
  value       = openstack_lb_loadbalancer_v2.lb.vip_address
}

output "lb_floating_ip" {
  description = "Floating IP of the load balancer"
  value       = var.enable_floating_ip ? openstack_networking_floatingip_v2.lb_fip[0].address : null
}

output "lb_endpoint" {
  description = "Load balancer endpoint URL"
  value       = var.enable_floating_ip ? "http://${openstack_networking_floatingip_v2.lb_fip[0].address}:${var.port}" : "http://${openstack_lb_loadbalancer_v2.lb.vip_address}:${var.port}"
}

output "pool_id" {
  description = "ID of the load balancer pool"
  value       = openstack_lb_pool_v2.pool.id
}

output "listener_id" {
  description = "ID of the load balancer listener"
  value       = openstack_lb_listener_v2.listener.id
}