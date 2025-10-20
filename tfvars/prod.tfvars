project_name = "terratech"
environment  = "prod"

external_network = "ntnu-internal"
ssh_key_name     = "my-keypair"

web_tier_cidr = "10.10.1.0/24"
app_tier_cidr = "10.10.2.0/24"
db_tier_cidr  = "10.10.3.0/24"

frontend_vm_count = 4
database_vm_count = 2
vm_flavor         = "gx2.4c4r"
vm_image          = "Debian 13 (Trixie) stable amd64"

enable_load_balancer = true
lb_protocol          = "HTTP"
lb_port              = 80
lb_method            = "ROUND_ROBIN"

enable_persistent_storage = true
persistent_storage_size   = 50
enable_object_storage     = true
storage_container_names   = ["app-data", "backups", "logs"]

web_server_type = "nginx"
database_type   = "postgresql"
database_name   = "appdb"
database_user   = "appuser"

allowed_ssh_cidrs  = ["10.0.0.0/16"]
allowed_http_cidrs = ["10.0.0.0/16"]
allowed_db_cidrs   = ["10.10.0.0/16"]
