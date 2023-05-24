
resource "oci_core_subnet" "lb_subnet_public" {
  cidr_block        = cidrsubnet(var.vcn_cidr_block, 8, 0)
  display_name      = "lb_public_subnet"
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.orangehrm_vcn.id
  route_table_id    = oci_core_route_table.public_route_table.id
  security_list_ids = [oci_core_security_list.public_security_list_http.id]
  dhcp_options_id   = oci_core_vcn.orangehrm_vcn.default_dhcp_options_id
  dns_label         = "lbpub"
}

resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.orangehrm_vcn.id
  display_name   = "RouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.orangehrm_internet_gateway.id
  }
}

resource "oci_core_internet_gateway" "orangehrm_internet_gateway" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.orangehrm_vcn.id
  enabled        = "true"
  display_name   = "${var.vcn_display_name}-igw"
}


resource "oci_core_security_list" "public_security_list_http" {
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
    source   = "0.0.0.0/0"
  }
  ingress_security_rules {
    tcp_options {
      max = 443
      min = 443
    }
    protocol = "6"
    source   = "0.0.0.0/0"
  }
}
