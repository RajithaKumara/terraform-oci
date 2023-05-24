resource "oci_load_balancer" "lb01" {
  shape = var.lb_shape

  dynamic "shape_details" {
    for_each = local.is_flexible_lb_shape ? [1] : []
    content {
      minimum_bandwidth_in_mbps = var.flex_lb_min_shape
      maximum_bandwidth_in_mbps = var.flex_lb_max_shape
    }
  }

  is_private = false

  #   reserved_ips {
  #     id = oci_core_public_ip.orangehrm_lb_public_ip.id
  #   }

  compartment_id = var.compartment_ocid

  subnet_ids = [
    var.lb_subnet_id,
  ]

  display_name = "orangehrm_lb"
}

# resource "oci_core_public_ip" "orangehrm_lb_public_ip" {
#   compartment_id = var.compartment_ocid
#   display_name   = "orangehrm_lb_public_ip"
#   lifetime       = "RESERVED"
# }

resource "oci_load_balancer_backend_set" "lb_bes_orangehrm" {
  name             = "orangehrmLBBackentSet"
  load_balancer_id = oci_load_balancer.lb01.id
  policy           = "ROUND_ROBIN"

  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
    interval_ms         = "10000"
    return_code         = "200"
    timeout_in_millis   = "3000"
    retries             = "3"
  }
}

resource "oci_load_balancer_listener" "lb_listener_orangehrm" {
  load_balancer_id         = oci_load_balancer.lb01.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb_bes_orangehrm.name
  port                     = 80
  protocol                 = "HTTP"
}

resource "oci_load_balancer_backend" "lb_be_orangehrm1" {
  load_balancer_id = oci_load_balancer.lb01.id
  backendset_name  = oci_load_balancer_backend_set.lb_bes_orangehrm.name
  ip_address       = oci_core_instance.orangehrm.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

# resource "oci_load_balancer_backend" "lb_be_orangehrm2plus" {
#   count            = var.numberOfNodes > 1 ? var.numberOfNodes - 1 : 0
#   load_balancer_id = oci_load_balancer.lb01[0].id
#   backendset_name  = oci_load_balancer_backend_set.lb_bes_orangehrm[0].name
#   ip_address       = oci_core_instance.orangehrm_from_image[count.index].private_ip
#   port             = 80
#   backup           = false
#   drain            = false
#   offline          = false
#   weight           = 1
# }

