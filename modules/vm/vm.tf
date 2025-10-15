data "openstack_images_image_v2" "image" {
  name        = var.distro
  most_recent = true
}

data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor
}



data "template_file" "script" {
  count    = var.cloud_init_template != "" ? 1 : 0
  template = var.cloud_init_template
}

data "template_cloudinit_config" "userdata" {
  count         = var.cloud_init_template != "" ? 1 : 0
  gzip          = true
  base64_encode = true

  part {
    filename     = "userdata"
    content      = data.template_file.script[0].rendered
    content_type = "text/x-shellscript"
  }
}

# Persistent storage volume
resource "openstack_blockstorage_volume_v3" "storage" {
  count = var.enable_persistent_storage ? 1 : 0
  
  name        = "${var.name}-storage"
  size        = var.persistent_storage_size
  description = "Persistent storage for ${var.name}"
  
  metadata = {
    vm_name    = var.name
    vm_type    = var.vm_type
    created_by = "terraform"
  }
}

resource "openstack_compute_instance_v2" "vm" {
  name      = var.name
  image_id  = data.openstack_images_image_v2.image.id
  flavor_id = data.openstack_compute_flavor_v2.flavor.id
  key_pair  = var.ssh_key_name
  
  security_groups = concat(
    [openstack_networking_secgroup_v2.secgroup.name, "default"],
    var.additional_security_groups
  )
  
  user_data = var.cloud_init_template == "" ? "" : data.template_cloudinit_config.userdata[0].rendered

network {
  uuid        = var.network_id
  fixed_ip_v4 = var.subnet_id != "" ? null : null
}

  
  metadata = {
    vm_type    = var.vm_type
    created_by = "terraform"
  }
}

# Attach persistent storage
resource "openstack_compute_volume_attach_v2" "storage_attachment" {
  count = var.enable_persistent_storage ? 1 : 0
  
  instance_id = openstack_compute_instance_v2.vm.id
  volume_id   = openstack_blockstorage_volume_v3.storage[0].id
  device      = var.storage_device
}

resource "openstack_networking_floatingip_v2" "fip" {
  count = var.enable_fip ? 1 : 0
  pool  = var.floating_ip_pool
}

resource "openstack_networking_port_v2" "port" {
  count      = var.enable_fip ? 1 : 0
  device_id  = openstack_compute_instance_v2.vm.id
  network_id = var.network_id
}

resource "openstack_networking_floatingip_associate_v2" "fip_associate" {
  count       = var.enable_fip ? 1 : 0
  floating_ip = openstack_networking_floatingip_v2.fip[0].address
  port_id     = openstack_networking_port_v2.port[0].id
}
