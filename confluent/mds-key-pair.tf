resource "tls_private_key" "mds_key_pair" {
  algorithm = "RSA"
}

resource "local_file" "mds_private_key" {
    content =  tls_private_key.mds_key_pair.private_key_pem
    filename = "generated_certs/mds-private-key.pem"
}
resource "local_file" "mds_public_key" {
    content =  tls_private_key.mds_key_pair.public_key_pem
    filename = "generated_certs/mds-public-key.pem"
}
