locals {
  platform_image_id = data.oci_core_images.autonomous_ol8.images[0].id

  is_flex_shape = contains(local.compute_flexible_shapes, var.vm_compute_shape)
  is_flexible_lb_shape   = var.lb_shape == "flexible" ? true : false

  # script_install_nodejs       = "/home/${var.vm_user}/install_nodejs.sh"
  # script_finalize          = "/home/${var.vm_user}/finalize.sh"
  home_dir                 = "/home/${var.vm_user}"
}

locals {
  compute_flexible_shapes = [
    "VM.Standard3.Flex",
    "VM.Standard.E3.Flex",
    "VM.Standard.E4.Flex",
    "VM.Standard.A1.Flex",
    "VM.DenseIO.E4.Flex",
    "VM.Optimized3.Flex"
  ]
}
