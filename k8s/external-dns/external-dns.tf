

resource "aws_iam_policy" "external_dns" {
  name        = "${var.resource_prefix}-external-dns"
  path        = "/"
  description = "Policy allows to manage hosted zone ${var.route_53_zone_id}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
                "route53:ChangeResourceRecordSets"
            ],
            "Resource": [
                "${var.route_53_zone_arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "route53:ListHostedZones",
                "route53:ListResourceRecordSets"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
  })
}

resource "aws_iam_role" "external_dns" {
  name = "${var.resource_prefix}-external-dns"
  assume_role_policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "",
                "Effect": "Allow",
                "Principal": {
                    "Federated": "${var.eks_oidc_provider_arn}"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "${var.eks_oidc_provider}:sub": "system:serviceaccount:kube-system:external-dns"
                    }
                }
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}