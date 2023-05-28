output "instance_public_ip" {
  value = oci_load_balancer.orangehrm_lb.ip_address_details[0].ip_address
}
