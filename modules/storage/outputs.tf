// Outputs for storage module, including volume IDs, names, and attachment info


output "volume_ids" {
  description = "IDs of created volumes"
  value       = { for name, volume in openstack_blockstorage_volume_v3.volumes : name => volume.id }
}

output "volume_names" {
  description = "Names of created volumes"
  value       = { for name, volume in openstack_blockstorage_volume_v3.volumes : name => volume.name }
}

output "attachment_info" {
  description = "Volume attachment information"
  value = { for name, attachment in openstack_compute_volume_attach_v2.attachments : name => {
    instance_id = attachment.instance_id
    volume_id   = attachment.volume_id
    device      = attachment.device
  } }
}