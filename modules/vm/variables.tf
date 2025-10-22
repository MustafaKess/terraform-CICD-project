// Variables for VM module configuration

variable "web_access_cidr" {
  description = "CIDR range allowed for HTTP/HTTPS access"
  type        = string
  default     = "0.0.0.0/0" # Default to allow all, should be restricted in production

  validation {
    condition     = can(cidrhost(var.web_access_cidr, 0))
    error_message = "The web_access_cidr value must be a valid CIDR range."
  }
}

variable "ssh_cidr" {
  description = "CIDR range allowed for SSH access"
  type        = string
  default     = "10.10.0.119/32" # Default to runner IP for security

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0))
    error_message = "The ssh_cidr value must be a valid CIDR range."
  }
}

variable "name" {
  description = "Name of the VM"
  type        = string
}

variable "network_id" {
  description = "ID of the network to attach VM to"
  type        = string
}

variable "subnet_id" {
  description = "ID of the specific subnet to attach VM to"
  type        = string
  default     = ""
}

variable "ssh_key_name" {
  description = "Name of the keypair in OpenStack"
  type        = string
}

variable "distro" {
  description = "Image name to use"
  type        = string
  default     = "Debian 13 (Trixie) stable amd64"
}

variable "flavor" {
  description = "VM flavor"
  type        = string
  default     = "gx1.1c1r"
}

variable "enable_fip" {
  description = "Whether to attach a floating IP"
  type        = bool
  default     = false
}

variable "floating_ip_pool" {
  description = "Floating IP pool name"
  type        = string
  default     = "ntnu-internal"
}

variable "cloud_init_template" {
  description = "Optional cloud-init template"
  type        = string
  default     = ""
}

variable "vm_type" {
  description = "Type of VM (frontend, database, app)"
  type        = string
  default     = "app"

  validation {
    condition     = contains(["frontend", "database", "app"], var.vm_type)
    error_message = "VM type must be one of: frontend, database, app."
  }
}

variable "enable_persistent_storage" {
  description = "Enable persistent storage volume attachment"
  type        = bool
  default     = false
}

variable "persistent_storage_size" {
  description = "Size of persistent storage in GB"
  type        = number
  default     = 20
}

variable "storage_device" {
  description = "Device path for attached storage"
  type        = string
  default     = "/dev/vdb"
}

variable "additional_security_groups" {
  description = "Additional security group names to attach"
  type        = list(string)
  default     = []
}
