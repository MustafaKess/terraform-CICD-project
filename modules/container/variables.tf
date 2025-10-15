// Variables for container module configuration

variable "project_name" {
  description = "Project name prefix for container naming"
  type        = string
}

variable "container_names" {
  description = "List of container names to create"
  type        = list(string)
}

variable "container_metadata" {
  description = "Metadata to assign to containers"
  type        = map(string)
  default     = {}
}

variable "container_read_acl" {
  description = "Read ACL for containers"
  type        = string
  default     = ""
}

variable "container_write_acl" {
  description = "Write ACL for containers"
  type        = string
  default     = ""
}

variable "container_sync_to" {
  description = "Sync destination for containers"
  type        = string
  default     = ""
}

variable "container_sync_key" {
  description = "Sync key for containers"
  type        = string
  default     = ""
  sensitive   = true
}

variable "enable_versioning" {
  description = "Enable versioning for containers"
  type        = bool
  default     = false
}