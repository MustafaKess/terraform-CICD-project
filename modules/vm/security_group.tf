// Module to create security groups and rules for VMs in OpenStack
// Security groups are tailored based on VM type (frontend, app, database)
// SSH is allowed for all VMs; HTTP/HTTPS for frontend; DB ports for database


locals {
  sg_name = "sg-${var.name}"
}

resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = local.sg_name
  description = "Security group for ${var.vm_type} VM ${var.name}"
}

# SSH access rule - always created
resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 22
  port_range_max    = 22
  protocol          = "tcp"
  remote_ip_prefix  = var.ssh_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# HTTP access rule - for frontend VMs
resource "openstack_networking_secgroup_rule_v2" "http" {
  count = var.vm_type == "frontend" ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 80
  port_range_max    = 80
  protocol          = "tcp"
  remote_ip_prefix  = var.web_access_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# HTTPS access rule - for frontend VMs
resource "openstack_networking_secgroup_rule_v2" "https" {
  count = var.vm_type == "frontend" ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 443
  port_range_max    = 443
  protocol          = "tcp"
  remote_ip_prefix  = var.web_access_cidr
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# MySQL access rule - for database VMs
resource "openstack_networking_secgroup_rule_v2" "mysql" {
  count = var.vm_type == "database" ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 3306
  port_range_max    = 3306
  protocol          = "tcp"
  remote_ip_prefix  = "10.0.0.0/16" # Only allow internal access
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# PostgreSQL access rule - for database VMs  
resource "openstack_networking_secgroup_rule_v2" "postgresql" {
  count = var.vm_type == "database" ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 5432
  port_range_max    = 5432
  protocol          = "tcp"
  remote_ip_prefix  = "10.0.0.0/16" # Only allow internal access
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# Custom application ports (8080, 8443) - for app tier VMs
resource "openstack_networking_secgroup_rule_v2" "app_http" {
  count = var.vm_type == "app" ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 8080
  port_range_max    = 8080
  protocol          = "tcp"
  remote_ip_prefix  = "10.0.0.0/16" # Only allow internal access
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "app_https" {
  count = var.vm_type == "app" ? 1 : 0

  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_min    = 8443
  port_range_max    = 8443
  protocol          = "tcp"
  remote_ip_prefix  = "10.0.0.0/16" # Only allow internal access
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

# ICMP (ping) rule - for all VMs
resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}
