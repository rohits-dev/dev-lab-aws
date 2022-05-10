resource "aws_security_group" "client_vpn" {
  name   = "${var.resource_prefix}_client_vpn"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "all"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "all"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

data "template_file" "vpn_config" {
  template = file("${path.module}/vpn.config")
  vars = {
    ca_crt     = var.root_ca_crt
    vpn_dns    = replace(aws_ec2_client_vpn_endpoint.client_vpn.dns_name, "*", "aws-lab")
    client_crt = tls_locally_signed_cert.vpn_client.cert_pem
    client_key = tls_private_key.vpn_client.private_key_pem
  }
}
resource "local_file" "vpn_config" {
  content  = data.template_file.vpn_config.rendered
  filename = "./client-vpn-config.ovpn"
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {

  description            = "${var.resource_prefix}-vpn"
  server_certificate_arn = aws_acm_certificate.vpn_server_crt.arn
  client_cidr_block      = "10.1.0.0/16"
  vpc_id                 = var.vpc_id
  dns_servers            = [cidrhost(var.vpc_cidr_block, 2)]
  split_tunnel           = true

  security_group_ids = [aws_security_group.client_vpn.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.root_ca_acm_arn
  }

  connection_log_options {
    enabled = false
  }
}

resource "null_resource" "configure_open_vpn_client" {
  depends_on = [local_file.vpn_config]

  provisioner "local-exec" {
    command = "/Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect --quit && /Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect --remove-profile=aws-lab && /Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect --import-profile=./client-vpn-config.ovpn --name=aws-lab && /Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect"
  }
}

resource "aws_ec2_client_vpn_network_association" "subnet_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.a_subnet_id
}

resource "aws_ec2_client_vpn_authorization_rule" "auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}
