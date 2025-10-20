// Variables for network module configuration

variable "network_name" {
  description = "Name of the network"
  type        = string
}

variable "web_tier_subnet_name" {
  description = "Name of the web tier subnet"
  type        = string
}

variable "app_tier_subnet_name" {
  description = "Name of the app tier subnet"
  type        = string
}

variable "db_tier_subnet_name" {
  description = "Name of the database tier subnet"
  type        = string
}

variable "web_tier_cidr" {
  description = "CIDR of the web tier subnet"
  type        = string
}

variable "app_tier_cidr" {
  description = "CIDR of the app tier subnet"
  type        = string
}

variable "db_tier_cidr" {
  description = "CIDR of the database tier subnet"
  type        = string
}

variable "router_name" {
  description = "Name of the router"
  type        = string
}

variable "external_network" {
  description = "Name of external network"
  type        = string
}
