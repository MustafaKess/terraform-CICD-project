// Variables for load balancer module configuration

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for load balancer VIP"
  type        = string
}

variable "description" {
  description = "Description of the load balancer"
  type        = string
  default     = "Load balancer created by Terraform"
}

variable "tags" {
  description = "Tags to apply to the load balancer"
  type        = list(string)
  default     = []
}

variable "enable_floating_ip" {
  description = "Enable floating IP for load balancer"
  type        = bool
  default     = true
}

variable "floating_ip_pool" {
  description = "Floating IP pool name"
  type        = string
  default     = "ntnu-internal"
}

variable "protocol" {
  description = "Load balancer protocol"
  type        = string
  default     = "HTTP"
  
  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "TERMINATED_HTTPS"], var.protocol)
    error_message = "Protocol must be one of: HTTP, HTTPS, TCP, TERMINATED_HTTPS."
  }
}

variable "port" {
  description = "Load balancer port"
  type        = number
  default     = 80
}

variable "lb_method" {
  description = "Load balancing method"
  type        = string
  default     = "ROUND_ROBIN"
  
  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_CONNECTIONS", "SOURCE_IP"], var.lb_method)
    error_message = "LB method must be one of: ROUND_ROBIN, LEAST_CONNECTIONS, SOURCE_IP."
  }
}

variable "backend_members" {
  description = "Map of backend members for load balancer"
  type = map(object({
    address = string
    port    = number
    weight  = number
  }))
  default = {}
}

variable "persistence_type" {
  description = "Session persistence type"
  type        = string
  default     = ""
  
  validation {
    condition     = var.persistence_type == "" || contains(["SOURCE_IP", "HTTP_COOKIE", "APP_COOKIE"], var.persistence_type)
    error_message = "Persistence type must be empty or one of: SOURCE_IP, HTTP_COOKIE, APP_COOKIE."
  }
}

variable "persistence_cookie_name" {
  description = "Cookie name for session persistence"
  type        = string
  default     = ""
}

variable "insert_headers" {
  description = "Headers to insert"
  type        = map(string)
  default     = {}
}

variable "timeout_client_data" {
  description = "Client data timeout in milliseconds"
  type        = number
  default     = 50000
}

variable "timeout_member_connect" {
  description = "Member connect timeout in milliseconds"
  type        = number
  default     = 5000
}

variable "timeout_member_data" {
  description = "Member data timeout in milliseconds"
  type        = number
  default     = 50000
}

variable "timeout_tcp_inspect" {
  description = "TCP inspect timeout in milliseconds"
  type        = number
  default     = 0
}

variable "enable_health_monitor" {
  description = "Enable health monitoring"
  type        = bool
  default     = true
}

variable "monitor_type" {
  description = "Health monitor type"
  type        = string
  default     = "HTTP"
  
  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "PING"], var.monitor_type)
    error_message = "Monitor type must be one of: HTTP, HTTPS, TCP, PING."
  }
}

variable "monitor_delay" {
  description = "Health check delay in seconds"
  type        = number
  default     = 10
}

variable "monitor_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "monitor_max_retries" {
  description = "Maximum health check retries"
  type        = number
  default     = 3
}

variable "monitor_url_path" {
  description = "URL path for HTTP health checks"
  type        = string
  default     = "/"
}

variable "monitor_http_method" {
  description = "HTTP method for health checks"
  type        = string
  default     = "GET"
}

variable "monitor_expected_codes" {
  description = "Expected HTTP response codes"
  type        = string
  default     = "200"
}