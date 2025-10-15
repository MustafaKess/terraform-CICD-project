// Outputs for VM module, including VM details and associated resources   

output "vm_name" {
  description = "Name of the VM"
  value       = openstack_compute_instance_v2.vm.name
}

output "vm_id" {
  description = "ID of the VM"
  value       = openstack_compute_instance_v2.vm.id
}

output "vm_ip" {
  description = "Internal IP address of the VM"
  value       = openstack_compute_instance_v2.vm.access_ip_v4
}

output "vm_fip" {
  description = "Floating IP address of the VM"
  value       = var.enable_fip ? openstack_networking_floatingip_v2.fip[0].address : null
}

output "security_group_id" {
  description = "ID of the VM security group"
  value       = openstack_networking_secgroup_v2.secgroup.id
}

output "security_group_name" {
  description = "Name of the VM security group"
  value       = openstack_networking_secgroup_v2.secgroup.name
}

output "storage_volume_id" {
  description = "ID of the persistent storage volume"
  value       = var.enable_persistent_storage ? openstack_blockstorage_volume_v3.storage[0].id : null
}

output "storage_volume_name" {
  description = "Name of the persistent storage volume"
  value       = var.enable_persistent_storage ? openstack_blockstorage_volume_v3.storage[0].name : null
}
