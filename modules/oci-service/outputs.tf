################################################################################
# OCI Additional Services Module - Outputs
################################################################################

# Block Volume Outputs
output "block_volume_ids" {
  description = "IDs of created block volumes"
  value       = { for k, v in oci_core_volume.block_volumes : k => v.id }
}

output "block_volume_attachment_commands" {
  description = "Commands to attach block volumes to instances"
  value = {
    for k, v in oci_core_volume.block_volumes : k => 
    "sudo iscsiadm -m node -o new -T ${v.iqn} -p ${v.iscsi_attach_commands[0].ipv4}:${v.iscsi_attach_commands[0].port}"
  }
}

# Object Storage Outputs
output "object_storage_bucket_names" {
  description = "Names of created object storage buckets"
  value       = { for k, v in oci_objectstorage_bucket.buckets : k => v.name }
}

output "object_storage_bucket_urls" {
  description = "URLs of created object storage buckets"
  value = {
    for k, v in oci_objectstorage_bucket.buckets : k => 
    "https://objectstorage.${var.region}.oraclecloud.com/n/${v.namespace}/b/${v.name}/o/"
  }
}

# Queue Outputs
output "queue_ids" {
  description = "IDs of created queues"
  value       = { for k, v in oci_queue_queue.queues : k => v.id }
}

output "queue_endpoints" {
  description = "Endpoints of created queues"
  value       = { for k, v in oci_queue_queue.queues : k => v.messages_endpoint }
}

# Virtual Machine Outputs
output "virtual_machine_ids" {
  description = "IDs of created virtual machines"
  value       = { for k, v in oci_core_instance.virtual_machines : k => v.id }
}

output "virtual_machine_private_ips" {
  description = "Private IP addresses of created virtual machines"
  value       = { for k, v in oci_core_instance.virtual_machines : k => v.private_ip }
}

output "virtual_machine_public_ips" {
  description = "Public IP addresses of created virtual machines (if any)"
  value       = { for k, v in oci_core_instance.virtual_machines : k => v.public_ip }
}

# Database Outputs
output "database_system_ids" {
  description = "IDs of created database systems"
  value       = { for k, v in oci_database_db_system.database_systems : k => v.id }
}

output "database_connection_strings" {
  description = "Connection strings for created databases"
  value = {
    for k, v in oci_database_db_system.database_systems : k => {
      hostname = v.hostname
      port     = v.listener_port
      service_name = "${v.db_home[0].database[0].db_name}.${var.region}.oraclecloud.com"
    }
  }
  sensitive = true
}
