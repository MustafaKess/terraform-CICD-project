// Variable definitions for the 3-tier web application infrastructure
// Includes project, OpenStack, network, VM, load balancer, storage, security,
// and application configuration variables


# Project Configuration
variable "project_name" {
  description = "Name of the project (used as prefix for resources)"
  type        = string
  default     = "terratech"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# OpenStack Configuration
variable "external_network" {
  description = "Name of the external network in OpenStack"
  type        = string
  default     = "ntnu-internal"
}

variable "ssh_key_name" {
  description = "Name of the SSH keypair in OpenStack"
  type        = string
  default     = "my-keypair"
}

# Network Configuration - 3-Tier Architecture
variable "network_name" {
  description = "Name of the main network"
  type        = string
  default     = ""
}

variable "web_tier_subnet_name" {
  description = "Name of the web tier subnet"
  type        = string
  default     = ""
}

variable "app_tier_subnet_name" {
  description = "Name of the app tier subnet"
  type        = string
  default     = ""
}

variable "db_tier_subnet_name" {
  description = "Name of the database tier subnet"
  type        = string
  default     = ""
}

variable "web_tier_cidr" {
  description = "CIDR block for web tier subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "app_tier_cidr" {
  description = "CIDR block for app tier subnet"  
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_tier_cidr" {
  description = "CIDR block for database tier subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "router_name" {
  description = "Name of the router"
  type        = string
  default     = ""
}

# Virtual Machine Configuration
variable "frontend_vm_count" {
  description = "Number of frontend VMs to create"
  type        = number
  default     = 2
}

variable "database_vm_count" {
  description = "Number of database VMs to create"
  type        = number
  default     = 1
}

variable "frontend_vm_name_prefix" {
  description = "Prefix for frontend VM names"
  type        = string
  default     = "frontend"
}

variable "database_vm_name_prefix" {
  description = "Prefix for database VM names"
  type        = string
  default     = "database"
}

variable "vm_flavor" {
  description = "OpenStack flavor for VMs"
  type        = string
  default     = "gx1.1c1r"
}

variable "vm_image" {
  description = "OpenStack image name for VMs"
  type        = string
  default     = "Debian 13 (Trixie) stable amd64"
}

# Load Balancer Configuration
variable "enable_load_balancer" {
  description = "Enable load balancer for frontend VMs"
  type        = bool
  default     = true
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
  default     = ""
}

variable "lb_protocol" {
  description = "Load balancer protocol"
  type        = string
  default     = "HTTP"
}

variable "lb_port" {
  description = "Load balancer port"
  type        = number
  default     = 80
}

variable "lb_method" {
  description = "Load balancing method"
  type        = string
  default     = "ROUND_ROBIN"
}

# Storage Configuration
variable "enable_persistent_storage" {
  description = "Enable persistent storage volumes"
  type        = bool
  default     = true
}

variable "persistent_storage_size" {
  description = "Size of persistent storage volumes in GB"
  type        = number
  default     = 20
}

variable "storage_volume_type" {
  description = "Type of storage volume"
  type        = string
  default     = "__DEFAULT__"
}

variable "enable_object_storage" {
  description = "Enable object storage containers"
  type        = bool
  default     = true
}

variable "storage_container_names" {
  description = "List of object storage container names"
  type        = list(string)
  default     = ["app-data", "backups", "logs"]
}

# Security Configuration
variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_http_cidrs" {
  description = "CIDR blocks allowed for HTTP access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_db_cidrs" {
  description = "CIDR blocks allowed for database access (internal only)"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# Application Configuration
variable "web_server_type" {
  description = "Web server type (apache or nginx)"
  type        = string
  default     = "nginx"
  
  validation {
    condition     = contains(["apache", "nginx"], var.web_server_type)
    error_message = "Web server type must be either 'apache' or 'nginx'."
  }
}

variable "database_type" {
  description = "Database type (mysql or postgresql)"
  type        = string
  default     = "postgresql"
  
  validation {
    condition     = contains(["mysql", "postgresql"], var.database_type)
    error_message = "Database type must be either 'mysql' or 'postgresql'."
  }
}

variable "database_name" {
  description = "Name of the application database"
  type        = string
  default     = "appdb"
}

variable "database_user" {
  description = "Database user name"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Database password (injected from environment variable OS_PASSWORD)"
  type        = string
  sensitive   = true
}
