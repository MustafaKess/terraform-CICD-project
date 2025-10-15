// Data source to fetch the external network by name
// Resources to create the main network, subnets for web, app, and db tiers
// Router and router interfaces to connect subnets to the external network


data "openstack_networking_network_v2" "external" {
  name = var.external_network
}

# Main network
resource "openstack_networking_network_v2" "net" {
  name           = var.network_name
  admin_state_up = true
}

# Web Tier Subnet
resource "openstack_networking_subnet_v2" "web_subnet" {
  name            = var.web_tier_subnet_name
  network_id      = openstack_networking_network_v2.net.id
  cidr            = var.web_tier_cidr
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# App Tier Subnet  
resource "openstack_networking_subnet_v2" "app_subnet" {
  name            = var.app_tier_subnet_name
  network_id      = openstack_networking_network_v2.net.id
  cidr            = var.app_tier_cidr
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# Database Tier Subnet
resource "openstack_networking_subnet_v2" "db_subnet" {
  name            = var.db_tier_subnet_name
  network_id      = openstack_networking_network_v2.net.id
  cidr            = var.db_tier_cidr
  ip_version      = 4
  enable_dhcp     = true
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# Router
resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

# Router interfaces for each tier
resource "openstack_networking_router_interface_v2" "web_router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.web_subnet.id
}

resource "openstack_networking_router_interface_v2" "app_router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.app_subnet.id
}

resource "openstack_networking_router_interface_v2" "db_router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.db_subnet.id
}
