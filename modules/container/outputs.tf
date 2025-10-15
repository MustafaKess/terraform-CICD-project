// Outputs for container module, including container names and URLs

output "container_names" {
  description = "Names of created containers"
  value       = [for container in openstack_objectstorage_container_v1.containers : container.name]
}

output "container_urls" {
  description = "URLs of created containers"
  value       = { for name, container in openstack_objectstorage_container_v1.containers : name => "swift://${container.name}" }
}