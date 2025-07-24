################################################################################
# OCI OKE Cluster
################################################################################

resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  vcn_id             = var.vcn_id
  
  endpoint_config {
    is_public_ip_enabled = true
    subnet_id            = var.private_subnet_ids[0]
  }
  
  options {
    add_ons {
      is_kubernetes_dashboard_enabled = false
      is_tiller_enabled               = false
    }
    
    kubernetes_network_config {
      pods_cidr     = "10.244.0.0/16"
      services_cidr = "10.96.0.0/16"
    }
    
    service_lb_subnet_ids = var.private_subnet_ids
  }
  
  freeform_tags = var.tags
}

################################################################################
# Node Pools
################################################################################

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

data "oci_core_images" "node_pool_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = values(var.node_groups)[0].instance_types[0]
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_containerengine_node_pool" "oke_node_pool" {
  for_each = var.node_groups
  
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_id
  kubernetes_version = var.kubernetes_version
  name               = each.key
  
  node_shape = each.value.instance_types[0]
  
  node_shape_config {
    memory_in_gbs = 16
    ocpus         = 1
  }
  
  node_config_details {
    size = each.value.desired_size
    
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.ads.availability_domains
      content {
        availability_domain = placement_configs.value.name
        subnet_id           = var.private_subnet_ids[placement_configs.key % length(var.private_subnet_ids)]
      }
    }
    
    freeform_tags = merge(
      each.value.labels,
      var.tags
    )
    
    # Use the latest Oracle Linux 8 image
    node_pool_pod_network_option_details {
      cni_type = "FLANNEL_OVERLAY"
    }
  }
  
  node_source_details {
    image_id    = data.oci_core_images.node_pool_images.images[0].id
    source_type = "IMAGE"
  }
  
  dynamic "initial_node_labels" {
    for_each = each.value.labels
    content {
      key   = initial_node_labels.key
      value = initial_node_labels.value
    }
  }
  
  dynamic "node_eviction_node_pool_settings" {
    for_each = each.value.taints
    content {
      eviction_grace_duration              = "PT1H"
      is_force_delete_after_grace_duration = false
    }
  }
  
  freeform_tags = var.tags
}

################################################################################
# Kubeconfig
################################################################################

data "oci_containerengine_cluster_kube_config" "oke_cluster_kube_config" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id
  
  token_version = "2.0.0"
}

resource "local_file" "kubeconfig" {
  content  = data.oci_containerengine_cluster_kube_config.oke_cluster_kube_config.content
  filename = "${path.module}/kubeconfig_${var.cluster_name}"
}