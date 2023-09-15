resource "kubernetes_namespace" "confluent" {
  metadata {
    name = "confluent"
    labels = {
      # protected = "true"
    }

  }
  lifecycle {
    ignore_changes = [
      # metadata[0].labels,
    ]
  }

}
locals {
  confluent_tier_storage_bucket_name = "${var.resource_prefix}-confluent"
}

resource "aws_s3_bucket" "confluent_tier_storage" {
  bucket        = local.confluent_tier_storage_bucket_name
  force_destroy = true
}



resource "aws_iam_policy" "confluent" {
  name        = "${var.resource_prefix}-confluent"
  path        = "/"
  description = "Policy allows to store tiered storage data in S3 in EKS cluster ${var.resource_prefix}-eks-1"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ],
        "Resource" : ["${aws_s3_bucket.confluent_tier_storage.arn}/*", aws_s3_bucket.confluent_tier_storage.arn]
      }
    ]
  })
}

resource "aws_iam_role" "confluent" {
  name = "${var.resource_prefix}-confluent"
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
          "StringLike" : {
            "${var.eks_oidc_provider}:sub" : "system:serviceaccount:*:kafka"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "confluent" {
  role       = aws_iam_role.confluent.name
  policy_arn = aws_iam_policy.confluent.arn
}


resource "kubernetes_secret" "mds_token_key_pair" {
  depends_on = [kubernetes_namespace.confluent]

  metadata {
    name      = "mds-token-keypair"
    namespace = "confluent"
  }

  data = {
    "mdsPublicKey.pem"    = tls_private_key.mds_key_pair.public_key_pem
    "mdsTokenKeyPair.pem" = tls_private_key.mds_key_pair.private_key_pem
  }
  type = "Opaque"
}
