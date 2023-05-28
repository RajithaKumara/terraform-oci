data "oci_core_images" "autonomous_ol8" {
  compartment_id   = var.compartment_ocid
  operating_system = "Oracle Autonomous Linux"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"
  state            = "AVAILABLE"

  # filter restricts to OL 8
  filter {
    name   = "operating_system_version"
    values = ["8\\.[0-9]"]
    regex  = true
  }
}

# data "template_file" "install_nodejs" {
#   template = file("${path.module}/scripts/install_nodejs.sh")
# }

data "template_file" "init_script" {
  template = file("${path.module}/scripts/init.sh.tpl")
  vars = {
    home_dir       = local.home_dir
  }
}

data "template_cloudinit_config" "cloud_init" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.init_script.rendered
  }
}

data "oci_core_vnic_attachments" "orangehrm_vnics" {
  depends_on          = [oci_core_instance.orangehrm]
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain_name
  instance_id         = oci_core_instance.orangehrm.id
}

data "oci_core_vnic" "orangehrm_vnic1" {
  depends_on = [oci_core_instance.orangehrm]
  vnic_id    = data.oci_core_vnic_attachments.orangehrm_vnics.vnic_attachments[0]["vnic_id"]
}

data "oci_core_private_ips" "orangehrm_private_ips1" {
  depends_on = [oci_core_instance.orangehrm]
  vnic_id    = data.oci_core_vnic.orangehrm_vnic1.id
  subnet_id  = var.subnet_id
}
