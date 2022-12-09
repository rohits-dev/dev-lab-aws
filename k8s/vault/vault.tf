//--------------------------------------------------------------------
// Resources

resource "aws_kms_key" "vault" {
  description             = "${var.resource_prefix} Vault unseal key"
  deletion_window_in_days = 7

  tags = {
    Name = "${var.resource_prefix}-vault-kms-unseal-key"
  }
}

resource "aws_kms_alias" "vault" {
  name          = "alias/${var.resource_prefix}-vault-kms-unseal-key"
  target_key_id = aws_kms_key.vault.key_id
}


resource "aws_iam_policy" "vault" {
  name        = "${var.resource_prefix}-vault"
  path        = "/"
  description = "Policy allows to manage kms for vault in EKS cluster ${var.resource_prefix}-eks-1"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {

        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Resource" : "${aws_kms_key.vault.arn}",
        "Effect" : "Allow"
      },
      {
        "Effect" : "Allow",
        "Action" : ["s3:ListBucket"],
        "Resource" : ["${aws_s3_bucket.vault.arn}"]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource" : ["${aws_s3_bucket.vault.arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role" "vault" {
  name = "${var.resource_prefix}-vault"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "${var.eks_oidc_provider_arn}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${var.eks_oidc_provider}:sub" : "system:serviceaccount:vault:vault"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vault" {
  role       = aws_iam_role.vault.name
  policy_arn = aws_iam_policy.vault.arn
}



# Generate Client Certificate

resource "tls_private_key" "vault_certificate" {
  algorithm = "RSA"
}

resource "tls_cert_request" "vault_certificate" {
  key_algorithm   = "RSA"
  private_key_pem = tls_private_key.vault_certificate.private_key_pem

  subject {
    common_name  = "vault"
    organization = "My Local, Inc"
  }
  dns_names = [
    "vault.${var.resource_prefix}.local",
    "vault-internal",
    "vault-0",
    "vault-1",
    "vault-2",
    "vault-3",
    "vault-4",

    "vault-0.vault-internal",
    "vault-1.vault-internal",
    "vault-2.vault-internal",
    "vault-3.vault-internal",
    "vault-4.vault-internal",

    "vault-internal.vault.svc.cluster.local",
    "vault-0.vault-internal.vault.svc.cluster.local",
    "vault-1.vault-internal.vault.svc.cluster.local",
    "vault-2.vault-internal.vault.svc.cluster.local",
    "vault-3.vault-internal.vault.svc.cluster.local",
    "vault-4.vault-internal.vault.svc.cluster.local",

    "vault-ui",
    "vault-ui.vault.svc.cluster.local"
  ]
}
resource "tls_locally_signed_cert" "vault_certificate" {
  cert_request_pem      = tls_cert_request.vault_certificate.cert_request_pem
  ca_key_algorithm      = "RSA"
  ca_private_key_pem    = var.root_ca_key
  ca_cert_pem           = var.root_ca_crt
  validity_period_hours = 8760 #1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}
resource "local_file" "vault_crt" {
  content  = tls_locally_signed_cert.vault_certificate.cert_pem
  filename = "generated_certs/vault.crt"
}
resource "local_file" "vault_key" {
  content  = tls_private_key.vault_certificate.private_key_pem
  filename = "generated_certs/vault.key"
}

# S3 bucket for initialization
resource "aws_s3_bucket" "vault" {
  bucket        = local.vault_s3_bucket_name
  force_destroy = true

}

resource "aws_s3_bucket_acl" "vault" {
  bucket = aws_s3_bucket.vault.id
  acl    = "private"
}
