resource "oci_load_balancer" "orangehrm_lb" {
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
  name             = "orangehrm-lb-backend-set"
  load_balancer_id = oci_load_balancer.orangehrm_lb.id
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
  load_balancer_id         = oci_load_balancer.orangehrm_lb.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb_bes_orangehrm.name
  port                     = 80
  protocol                 = "HTTP"
}

resource "oci_load_balancer_listener" "lb_listener_orangehrm_ssl" {
  depends_on = [ oci_load_balancer_certificate.temp_certificate ]

  load_balancer_id         = oci_load_balancer.orangehrm_lb.id
  name                     = "https"
  default_backend_set_name = oci_load_balancer_backend_set.lb_bes_orangehrm.name
  port                     = 443
  protocol                 = "HTTP"

  ssl_configuration {
    certificate_name        = "temp_ssl_certificate" 
    verify_peer_certificate = false
    protocols               = [ "TLSv1.2" ]
  }
}

resource "oci_load_balancer_backend" "lb_be_orangehrm1" {
  load_balancer_id = oci_load_balancer.orangehrm_lb.id
  backendset_name  = oci_load_balancer_backend_set.lb_bes_orangehrm.name
  ip_address       = oci_core_instance.orangehrm.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "oci_load_balancer_backend" "lb_be_orangehrm2plus" {
  load_balancer_id = oci_load_balancer.orangehrm_lb.id
  backendset_name  = oci_load_balancer_backend_set.lb_bes_orangehrm.name
  ip_address       = oci_core_instance.orangehrm_instance_2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}

resource "tls_private_key" "demo_private_key" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "tls_self_signed_cert" "demo_certificate" {
  private_key_pem   = tls_private_key.demo_private_key.private_key_pem

  subject {
    common_name         = "demo_certificate"
    organization        = "Example Org"
  }

  validity_period_hours = 30 * 24

  allowed_uses = [
    "digital_signature",
    "cert_signing",
    "crl_signing",
  ]
}

resource "oci_load_balancer_certificate" "temp_certificate" {
    certificate_name = "temp_ssl_certificate"
    load_balancer_id = oci_load_balancer.orangehrm_lb.id
    private_key = tls_private_key.demo_private_key.private_key_pem
    public_certificate = tls_self_signed_cert.demo_certificate.cert_pem
    lifecycle {
        create_before_destroy = true
    }
}
