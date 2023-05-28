variable "tenancy_ocid" {
}

variable "region" {
}

variable "compartment_ocid" {
}

variable "tag_key_name" {
  description = "Free-form tag key name"
  default     = "App"
}

variable "tag_value" {
  description = "Free-form tag value"
  default     = "OrangeHRM"
}

############################
#  Compute Configuration   #
############################

variable "availability_domain_name" {
  default     = ""
  description = "Availability Domain name"
}

variable "vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard.E3.Flex"
}

variable "vm_flex_shape_ocpus" {
  description = "Flex Instance shape OCPUs"
  default     = 1
}

variable "vm_flex_shape_memory" {
  description = "Flex Instance shape Memory (GB)"
  default     = 6
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "vm_user" {
  description = "The SSH user to connect to the master host."
  default     = "opc"
}

############################
#  Network Configuration   #
############################

variable "subnet_id" {
}

variable "vcn_id" {
}

############################
#      Load balancer       #
############################

variable "lb_shape" {
  default = "flexible"
}

variable "flex_lb_min_shape" {
  default = "10"
}

variable "flex_lb_max_shape" {
  default = "100"
}

variable "lb_subnet_id" {
  description = "The OCID of the Load Balancer subnet to create the VNIC for public access. "
  default     = ""
}
