// Container creation with dynamic names and optional settings

resource "openstack_objectstorage_container_v1" "containers" {
  for_each = toset(var.container_names)

  name               = "${var.project_name}-${each.key}"
  content_type       = "application/json"
  metadata           = var.container_metadata
  container_read     = var.container_read_acl
  container_write    = var.container_write_acl
  container_sync_to  = var.container_sync_to
  container_sync_key = var.container_sync_key
  versioning         = var.enable_versioning
}