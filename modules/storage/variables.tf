// Variables for storage module configuration

variable "project_name" {
  description = "Project name prefix for volume naming"
  type        = string
}

variable "volume_type" {
  description = "Type of volumes to create"
  type        = string
  default     = "__DEFAULT__"
}

variable "volumes" {
  description = "Map of volumes to create"
  type = map(object({
    size        = number
    description = string
    metadata    = map(string)
  }))
  default = {}
}

variable "attachments" {
  description = "Map of volume attachments"
  type = map(object({
    instance_id = string
    volume_key  = string
    device      = string
  }))
  default = {}
}