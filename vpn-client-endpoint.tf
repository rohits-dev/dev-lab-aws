resource "aws_security_group" "client_vpn" {
  name   = "${var.RESOURCE_PREFIX}_client_vpn"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "10.1.0.0/16",
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "tcp"

    cidr_blocks = [
      "10.1.0.0/16",
    ]
  }
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "${var.RESOURCE_PREFIX}-vpn"
  server_certificate_arn = var.ROOT_CA_ARN
  client_cidr_block      = "10.1.0.0/16"
  vpc_id                 = module.vpc.vpc_id
  dns_servers            = ["10.0.0.2"]
  split_tunnel           = true

  security_group_ids = [aws_security_group.client_vpn.id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.ROOT_CA_ARN
  }

  connection_log_options {
    enabled = false
  }

  tags = {
    Name  = "rohit-vpn"
    OWNER = "rohit"
  }
  provisioner "local-exec" {
    command = "aws s3 cp ${var.OPENVPN_CONFIG_S3_URL} . && sed -i '' 's/REMOTE_URL/${replace(aws_ec2_client_vpn_endpoint.client_vpn.dns_name, "*","vpntoaws")}/g' ./client-vpn-config.ovpn && /Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect --quit && /Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect --remove-profile=aws-lab && /Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect --import-profile=./client-vpn-config.ovpn --name=aws-lab && /Applications/OpenVPN\\ Connect/OpenVPN\\ Connect.app/Contents/MacOS/OpenVPN\\ Connect"
  }
}


resource "aws_ec2_client_vpn_network_association" "example" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = module.vpc.public_subnets[0]
}

resource "aws_ec2_client_vpn_authorization_rule" "example" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = module.vpc.vpc_cidr_block
  authorize_all_groups   = true
}
