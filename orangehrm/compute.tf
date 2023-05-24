resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "oci_core_instance" "orangehrm" {
  availability_domain = var.availability_domain_name
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_display_name
  shape               = var.vm_compute_shape

  source_details {
    source_type = "image"
    source_id   = local.platform_image_id
  }

  dynamic "shape_config" {
    for_each = local.is_flex_shape ? [1] : []
    content {
      memory_in_gbs = var.vm_flex_shape_memory
      ocpus         = var.vm_flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id              = var.subnet_id
    display_name           = var.subnet_display_name
    assign_public_ip       = false
    skip_source_dest_check = false
  }

  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
    user_data           = data.template_cloudinit_config.cloud_init.rendered
  }
}

# resource "null_resource" "orangehrm_provisioner" {
#   depends_on = [oci_core_instance.orangehrm, oci_core_public_ip.orangehrm_public_ip_for_single_node]

#   provisioner "file" {
#     content     = data.template_file.install_nodejs.rendered
#     destination = local.script_install_nodejs

#     connection {
#       type        = "ssh"
#       host        = oci_core_public_ip.orangehrm_public_ip_for_single_node.ip_address
#       agent       = false
#       timeout     = "5m"
#       user        = var.vm_user
#       private_key = tls_private_key.public_private_key_pair.private_key_pem
#     }
#   }

#   provisioner "file" {
#     source      = "${path.module}/app/"
#     destination = local.home_dir

#     connection {
#       type        = "ssh"
#       host        = oci_core_public_ip.orangehrm_public_ip_for_single_node.ip_address
#       agent       = false
#       timeout     = "5m"
#       user        = var.vm_user
#       private_key = tls_private_key.public_private_key_pair.private_key_pem
#     }
#   }

#   provisioner "file" {
#     content     = templatefile("${path.module}/scripts/finalize.sh", { home_dir = local.home_dir })
#     destination = local.script_finalize

#     connection {
#       type        = "ssh"
#       host        = oci_core_public_ip.orangehrm_public_ip_for_single_node.ip_address
#       agent       = false
#       timeout     = "5m"
#       user        = var.vm_user
#       private_key = tls_private_key.public_private_key_pair.private_key_pem
#     }
#   }

#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       host        = oci_core_public_ip.orangehrm_public_ip_for_single_node.ip_address
#       agent       = false
#       timeout     = "5m"
#       user        = var.vm_user
#       private_key = tls_private_key.public_private_key_pair.private_key_pem
#     }

#     inline = [
#       "chmod +x ${local.script_install_nodejs}",
#       "sudo ${local.script_install_nodejs}",
#       "chmod +x ${local.script_finalize}",
#       "sudo ${local.script_finalize}",
#     ]
#   }
# }

# resource "oci_core_public_ip" "orangehrm_public_ip_for_single_node" {
#   depends_on     = [oci_core_instance.orangehrm]
#   compartment_id = var.compartment_ocid
#   display_name   = "orangehrm_public_ip_for_single_node"
#   lifetime       = "RESERVED"
#   private_ip_id  = data.oci_core_private_ips.orangehrm_private_ips1.private_ips[0]["id"]
# }
