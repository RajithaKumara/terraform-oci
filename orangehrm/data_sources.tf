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

