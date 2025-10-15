// Output definitions for the 3-tier web application infrastructure
// Includes outputs from network, VM, load balancer, storage, and security configurations


# Network Outputs
output "network_id" {
  description = "ID of the main network"
  value       = module.network.network_id
}

output "web_subnet_id" {
  description = "ID of the web tier subnet"
  value       = module.network.web_subnet_id
}

output "app_subnet_id" {
  description = "ID of the app tier subnet"
  value       = module.network.app_subnet_id
}

output "db_subnet_id" {
  description = "ID of the database tier subnet"
  value       = module.network.db_subnet_id
}

output "router_id" {
  description = "ID of the router"
  value       = module.network.router_id
}

# Frontend VM Outputs
output "frontend_vm_ids" {
  description = "IDs of frontend VMs"
  value       = [for vm in module.frontend_vms : vm.vm_id]
}

output "frontend_vm_names" {
  description = "Names of frontend VMs"
  value       = [for vm in module.frontend_vms : vm.vm_name]
}

output "frontend_vm_ips" {
  description = "Internal IP addresses of frontend VMs"
  value       = [for vm in module.frontend_vms : vm.vm_ip]
}

output "frontend_vm_floating_ips" {
  description = "Floating IP addresses of frontend VMs"
  value       = [for vm in module.frontend_vms : vm.vm_fip]
}

# Database VM Outputs
output "database_vm_ids" {
  description = "IDs of database VMs"
  value       = [for vm in module.database_vms : vm.vm_id]
}

output "database_vm_names" {
  description = "Names of database VMs"
  value       = [for vm in module.database_vms : vm.vm_name]
}

output "database_vm_ips" {
  description = "Internal IP addresses of database VMs"
  value       = [for vm in module.database_vms : vm.vm_ip]
}

# Load Balancer Outputs
output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = var.enable_load_balancer ? module.load_balancer[0].lb_id : null
}

output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = var.enable_load_balancer ? module.load_balancer[0].lb_name : null
}

output "load_balancer_vip" {
  description = "VIP address of the load balancer"
  value       = var.enable_load_balancer ? module.load_balancer[0].lb_vip_address : null
}

output "load_balancer_floating_ip" {
  description = "Floating IP address of the load balancer"
  value       = var.enable_load_balancer ? module.load_balancer[0].lb_floating_ip : null
}

output "load_balancer_endpoint" {
  description = "Load balancer endpoint URL"
  value       = var.enable_load_balancer ? module.load_balancer[0].lb_endpoint : null
}

# Storage Outputs
output "frontend_storage_volumes" {
  description = "Storage volume information for frontend VMs"
  value = {
    for vm in module.frontend_vms : vm.vm_name => {
      volume_id   = vm.storage_volume_id
      volume_name = vm.storage_volume_name
    }
  }
}

output "database_storage_volumes" {
  description = "Storage volume information for database VMs"
  value = {
    for vm in module.database_vms : vm.vm_name => {
      volume_id   = vm.storage_volume_id
      volume_name = vm.storage_volume_name
    }
  }
}

# Object Storage Container Outputs
output "storage_container_names" {
  description = "Names of created storage containers"
  value       = var.enable_object_storage ? module.containers[0].container_names : []
}

output "storage_container_urls" {
  description = "URLs of created storage containers"
  value       = var.enable_object_storage ? module.containers[0].container_urls : {}
}

# Security Group Outputs
output "frontend_security_group_ids" {
  description = "Security group IDs for frontend VMs"
  value       = [for vm in module.frontend_vms : vm.security_group_id]
}

output "database_security_group_ids" {
  description = "Security group IDs for database VMs"
  value       = [for vm in module.database_vms : vm.security_group_id]
}

# Connection Information
output "ssh_connection_commands" {
  description = "SSH connection commands for VMs with floating IPs"
  value = {
    for vm in module.frontend_vms : vm.vm_name => "ssh -i ~/.ssh/your-key.pem debian@${vm.vm_fip}"
  }
  sensitive = false
}

output "database_connection_strings" {
  description = "Database connection information"
  value = {
    type     = var.database_type
    host     = length(module.database_vms) > 0 ? module.database_vms[0].vm_ip : ""
    port     = var.database_type == "postgresql" ? 5432 : 3306
    database = var.database_name
    username = var.database_user
  }
  sensitive = false
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    project_name          = var.project_name
    environment           = var.environment
    frontend_vm_count     = var.frontend_vm_count
    database_vm_count     = var.database_vm_count
    load_balancer_enabled = var.enable_load_balancer
    web_server_type       = var.web_server_type
    database_type         = var.database_type
    storage_enabled       = var.enable_persistent_storage
    containers_enabled    = var.enable_object_storage
    load_balancer_endpoint = var.enable_load_balancer ? module.load_balancer[0].lb_endpoint : "N/A"
  }
}