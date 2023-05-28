resource "oci_core_vcn" "orangehrm_vcn" {
  cidr_block     = var.vcn_cidr_block
  dns_label      = substr(var.vcn_dns_label, 0, 15)
  compartment_id = var.compartment_ocid
  display_name   = var.vcn_display_name
}

resource "oci_core_subnet" "orangehrm_subnet" {
  cidr_block                 = cidrsubnet(var.vcn_cidr_block, 8, 2)
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.orangehrm_vcn.id
  display_name               = var.subnet_display_name
  dns_label                  = substr(var.subnet_dns_label, 0, 15)
  prohibit_public_ip_on_vnic = true

  route_table_id    = oci_core_route_table.orangehrm_route_table.id
  security_list_ids = [oci_core_security_list.private_security_list_http.id]
}

resource "oci_core_route_table" "orangehrm_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.orangehrm_vcn.id
  display_name   = "RouteTableViaNATGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.nat_gateway.id
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.orangehrm_vcn.id
  display_name   = "nat_gateway"
}

resource "oci_core_security_list" "private_security_list_http" {
  compartment_id = var.compartment_ocid
  display_name   = "Allow HTTP(S) to orangehrm"
  vcn_id         = oci_core_vcn.orangehrm_vcn.id
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "6"
  }
  ingress_security_rules {
    tcp_options {
      max = 80
      min = 80
    }
    protocol = "6"
    source   = var.vcn_cidr_block
  }
  ingress_security_rules {
    tcp_options {
      max = 22
      min = 22
    }
    protocol = "6"
    source   = var.vcn_cidr_block
  }
}
