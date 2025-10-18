# Local values for resource naming
locals {
  project_name = var.project_name
  environment  = var.environment
  
  # Generate names with project prefix
  network_name         = var.network_name != "" ? var.network_name : "${local.project_name}-${local.environment}-network"
  web_tier_subnet_name = var.web_tier_subnet_name != "" ? var.web_tier_subnet_name : "${local.project_name}-${local.environment}-web-subnet"
  app_tier_subnet_name = var.app_tier_subnet_name != "" ? var.app_tier_subnet_name : "${local.project_name}-${local.environment}-app-subnet"
  db_tier_subnet_name  = var.db_tier_subnet_name != "" ? var.db_tier_subnet_name : "${local.project_name}-${local.environment}-db-subnet"
  router_name          = var.router_name != "" ? var.router_name : "${local.project_name}-${local.environment}-router"
  lb_name              = var.lb_name != "" ? var.lb_name : "${local.project_name}-${local.environment}-lb"
  
  # Cloud-init templates
  frontend_cloud_init = var.web_server_type == "nginx" ? file("${path.module}/cloud-init/frontend-nginx.sh") : file("${path.module}/cloud-init/frontend-apache.sh")
    
  database_cloud_init = templatefile("${path.module}/cloud-init/database-${var.database_type}.sh", {
    database_name     = var.database_name
    database_user     = var.database_user
    database_password = var.db_password
  })
}

# 3-Tier Network Infrastructure
module "network" {
  source = "./modules/network"
  
  network_name         = local.network_name
  web_tier_subnet_name = local.web_tier_subnet_name
  app_tier_subnet_name = local.app_tier_subnet_name
  db_tier_subnet_name  = local.db_tier_subnet_name
  web_tier_cidr        = var.web_tier_cidr
  app_tier_cidr        = var.app_tier_cidr
  db_tier_cidr         = var.db_tier_cidr
  router_name          = local.router_name
  external_network     = var.external_network
}

# Object Storage Containers
module "containers" {
  count  = var.enable_object_storage ? 1 : 0
  source = "./modules/container"
  
  project_name    = local.project_name
  container_names = var.storage_container_names
}

# Frontend VMs (Web Tier)
module "frontend_vms" {
  count  = var.frontend_vm_count
  source = "./modules/vm"
  
  name                     = "${var.frontend_vm_name_prefix}${format("%02d", count.index + 1)}"
  network_id               = module.network.network_id
  subnet_id                = module.network.web_subnet_id
  ssh_key_name             = var.ssh_key_name
  distro                   = var.vm_image
  flavor                   = var.vm_flavor
  vm_type                  = "frontend"
  enable_fip               = true
  floating_ip_pool         = var.external_network
  cloud_init_template      = local.frontend_cloud_init
  enable_persistent_storage = var.enable_persistent_storage
  persistent_storage_size   = var.persistent_storage_size
  storage_volume_type       = var.storage_volume_type
}

# Database VMs (Database Tier)
module "database_vms" {
  count  = var.database_vm_count
  source = "./modules/vm"
  
  name                     = "${var.database_vm_name_prefix}${format("%02d", count.index + 1)}"
  network_id               = module.network.network_id
  subnet_id                = module.network.db_subnet_id
  ssh_key_name             = var.ssh_key_name
  distro                   = var.vm_image
  flavor                   = var.vm_flavor
  vm_type                  = "database"
  enable_fip               = false  # Database VMs are internal only
  cloud_init_template      = local.database_cloud_init
  enable_persistent_storage = true  # Databases always need persistent storage
  persistent_storage_size   = var.persistent_storage_size * 2  # Larger storage for databases
  storage_volume_type       = var.storage_volume_type
}

# Load Balancer (Web Tier)
module "load_balancer" {
  count  = var.enable_load_balancer ? 1 : 0
  source = "./modules/loadbalancer"
  
  lb_name             = local.lb_name
  subnet_id           = module.network.web_subnet_id
  description         = "Load balancer for ${local.project_name} frontend servers"
  protocol            = var.lb_protocol
  port                = var.lb_port
  lb_method           = var.lb_method
  enable_floating_ip  = true
  floating_ip_pool    = var.external_network
  enable_health_monitor = true
  monitor_url_path    = "/health"
  
  # Backend members (frontend VMs)
  backend_members = {
    for i, vm in module.frontend_vms : "frontend-${i+1}" => {
      address = vm.vm_ip
      port    = var.lb_port
      weight  = 1
    }
  }
}
