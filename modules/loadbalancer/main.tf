// Load Balancer module 
// This module sets up a load balancer with optional floating IP and health monitoring
// It supports various protocols and load balancing methods, with backend member configuration
// and session persistence options.


resource "openstack_lb_loadbalancer_v2" "lb" {
  name          = var.lb_name
  vip_subnet_id = var.subnet_id
  description   = var.description

  tags = var.tags
}

resource "openstack_networking_floatingip_v2" "lb_fip" {
  count = var.enable_floating_ip ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "openstack_networking_floatingip_associate_v2" "lb_fip_associate" {
  count       = var.enable_floating_ip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.lb_fip[0].address
  port_id     = openstack_lb_loadbalancer_v2.lb.vip_port_id
}

resource "openstack_lb_listener_v2" "listener" {
  name                   = "${var.lb_name}-listener"
  protocol               = var.protocol
  protocol_port          = var.port
  loadbalancer_id        = openstack_lb_loadbalancer_v2.lb.id
  default_pool_id        = openstack_lb_pool_v2.pool.id
  insert_headers         = var.insert_headers
  timeout_client_data    = var.timeout_client_data
  timeout_member_connect = var.timeout_member_connect
  timeout_member_data    = var.timeout_member_data
  timeout_tcp_inspect    = var.timeout_tcp_inspect
}

resource "openstack_lb_pool_v2" "pool" {
  name            = "${var.lb_name}-pool"
  protocol        = var.protocol
  lb_method       = var.lb_method
  loadbalancer_id = openstack_lb_loadbalancer_v2.lb.id

  dynamic "persistence" {
    for_each = var.persistence_type != "" ? [1] : []
    content {
      type        = var.persistence_type
      cookie_name = var.persistence_cookie_name
    }
  }
}

resource "openstack_lb_member_v2" "members" {
  for_each = var.backend_members

  pool_id       = openstack_lb_pool_v2.pool.id
  address       = each.value.address
  protocol_port = each.value.port
  weight        = each.value.weight
  subnet_id     = var.subnet_id
}

resource "openstack_lb_monitor_v2" "monitor" {
  count = var.enable_health_monitor ? 1 : 0

  pool_id        = openstack_lb_pool_v2.pool.id
  type           = var.monitor_type
  delay          = var.monitor_delay
  timeout        = var.monitor_timeout
  max_retries    = var.monitor_max_retries
  url_path       = var.monitor_url_path
  http_method    = var.monitor_http_method
  expected_codes = var.monitor_expected_codes
}