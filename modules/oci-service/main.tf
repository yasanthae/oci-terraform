################################################################################
# OCI Additional Services Module - Main Configuration
################################################################################

# Get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

# Get the latest CentOS image
data "oci_core_images" "centos" {
    compartment_id           = var.compartment_id
    operating_system         = "CentOS"
    operating_system_version = "8"
    shape                    = "VM.Standard.E5.Flex"
    sort_by                  = "TIMECREATED"
    sort_order               = "DESC"
}

# Get the latest Windows Server image
data "oci_core_images" "windows_server" {
    compartment_id           = var.compartment_id
    operating_system         = "Windows"
    operating_system_version = "Server 2019 Standard"
    shape                    = "VM.Standard.E5.Flex"
    sort_by                  = "TIMECREATED"
    sort_order               = "DESC"
}

################################################################################
# Block Volumes
################################################################################

resource "oci_core_volume" "block_volumes" {
  for_each = var.block_volumes

  compartment_id      = var.compartment_id
  availability_domain = each.value.availability_domain != "" ? each.value.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "${var.project_name}-${var.environment}-${each.key}-volume"
  size_in_gbs         = each.value.size_in_gbs
  vpus_per_gb         = each.value.vpus_per_gb

  freeform_tags = merge(var.tags, {
    Name        = "${var.project_name}-${var.environment}-${each.key}-volume"
    Type        = "block-volume"
    Purpose     = each.key
  })
}

# Block Volume Backup Policy (if enabled)
resource "oci_core_volume_backup_policy_assignment" "block_volume_backup" {
  for_each = {
    for k, v in var.block_volumes : k => v if v.backup_policy_enabled
  }

  asset_id  = oci_core_volume.block_volumes[each.key].id
  policy_id = data.oci_core_volume_backup_policies.default_policies.volume_backup_policies[0].id
}

data "oci_core_volume_backup_policies" "default_policies" {
  filter {
    name   = "display_name"
    values = ["bronze"]
  }
}

################################################################################
# Object Storage Buckets
################################################################################

resource "oci_objectstorage_bucket" "buckets" {
  for_each = var.object_storage_buckets

  compartment_id = var.compartment_id
  name           = "${var.project_name}-${var.environment}-${each.key}-bucket"
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
  access_type    = each.value.access_type
  storage_tier   = each.value.storage_tier
  versioning     = each.value.versioning

  freeform_tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-${each.key}-bucket"
    Type    = "object-storage"
    Purpose = each.key
  })
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.compartment_id
}

################################################################################
# OCI Queues
################################################################################

resource "oci_queue_queue" "queues" {
  for_each = var.queues

  compartment_id                       = var.compartment_id
  display_name                        = "${var.project_name}-${var.environment}-${each.key}-queue"
  visibility_timeout_in_seconds       = each.value.visibility_timeout_in_seconds
  message_retention_period            = each.value.message_retention_period
  dead_letter_queue_delivery_count    = each.value.dead_letter_queue_delivery_count

  freeform_tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-${each.key}-queue"
    Type    = "queue"
    Purpose = each.key
  })
}

################################################################################
# Virtual Machines
################################################################################

resource "oci_core_instance" "virtual_machines" {
  for_each = var.virtual_machines

  compartment_id      = var.compartment_id
  availability_domain = each.value.availability_domain != "" ? each.value.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = each.value.shape
  display_name        = "${var.project_name}-${var.environment}-${each.key}-vm"

  dynamic "shape_config" {
    for_each = each.value.shape_config != null ? [each.value.shape_config] : []
    content {
      ocpus         = shape_config.value.ocpus
      memory_in_gbs = shape_config.value.memory_in_gbs
    }
  }

  create_vnic_details {
    subnet_id                 = var.subnet_id
    display_name              = "${var.project_name}-${var.environment}-${each.key}-vnic"
    assign_public_ip          = false
    assign_private_dns_record = true
    hostname_label            = "${var.project_name}-${var.environment}-${each.key}"
  }

  source_details {
    source_type = "image"
    source_id   = each.value.image_id != "" ? each.value.image_id : (
      each.value.operating_system == "windows" ? 
      data.oci_core_images.windows_server.images[0].id : 
      data.oci_core_images.centos.images[0].id
    )
    boot_volume_size_in_gbs = each.value.boot_volume_size_in_gbs
    boot_volume_vpus_per_gb = each.value.boot_volume_vpus_per_gb
  }

  # Metadata - conditional based on OS type
  metadata = each.value.operating_system == "windows" ? {} : {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }

  freeform_tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-${each.key}-vm"
    Type    = "virtual-machine"
    Purpose = each.key
  })
}

################################################################################
# Database Systems
################################################################################

resource "oci_database_db_system" "database_systems" {
  for_each = var.database_systems

  compartment_id      = var.compartment_id
  availability_domain = each.value.availability_domain != "" ? each.value.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name
  
  shape     = each.value.shape
  cpu_core_count = each.value.shape_config.ocpus
  
  database_edition = each.value.database_edition
  
  ssh_public_keys = [file("~/.ssh/id_rsa.pub")]
  
  display_name = "${var.project_name}-${var.environment}-${each.key}-db"
  hostname     = "${var.project_name}-${var.environment}-${each.key}-db"
  
  subnet_id = var.subnet_id
  
  data_storage_size_in_gb = each.value.storage_size_in_gbs
  
  # Database home configuration
  db_home {
    db_version   = "21.0.0.0"
    display_name = "${var.project_name}-${var.environment}-${each.key}-dbhome"
    
    database {
      admin_password = each.value.db_admin_password
      db_name        = each.value.db_name
      character_set  = "AL32UTF8"
      ncharacter_set = "AL16UTF16"
      db_workload    = "OLTP"
      pdb_name       = "${each.value.db_name}pdb"
    }
  }

  freeform_tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-${each.key}-db"
    Type    = "database"
    Purpose = each.key
  })
}
