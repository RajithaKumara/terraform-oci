
module "orangehrm" {
  source                   = "./orangehrm"
  tenancy_ocid             = var.tenancy_ocid
  region                   = var.region
  compartment_ocid         = var.compartment_ocid
  availability_domain_name = local.availability_domain
  vm_display_name          = var.vm_display_name
  vm_compute_shape         = var.vm_compute_shape
  vm_flex_shape_ocpus      = var.vm_flex_shape_ocpus
  vm_flex_shape_memory     = var.vm_flex_shape_memory
  ssh_authorized_keys      = var.ssh_public_key
  vcn_id                   = oci_core_vcn.orangehrm_vcn.id
  subnet_id                = oci_core_subnet.orangehrm_subnet.id
  subnet_display_name      = var.subnet_display_name
  lb_subnet_id             = oci_core_subnet.lb_subnet_public.id
}
