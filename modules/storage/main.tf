// Module to create and attach block storage volumes in OpenStack
// Define and create block storage volumes based on input variables
// Attach created volumes to specified instances

resource "openstack_blockstorage_volume_v3" "volumes" {
  for_each = var.volumes

  name        = "${var.project_name}-${each.key}"
  description = each.value.description
  size        = each.value.size
  volume_type = var.volume_type

  metadata = merge(
    {
      project    = var.project_name
      created_by = "terraform"
    },
    each.value.metadata
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "openstack_compute_volume_attach_v2" "attachments" {
  for_each = var.attachments

  instance_id = each.value.instance_id
  volume_id   = openstack_blockstorage_volume_v3.volumes[each.value.volume_key].id
  device      = each.value.device
}