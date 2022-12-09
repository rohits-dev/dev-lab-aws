resource "aws_iam_policy" "aws_load_balancer_controller" {
  name        = "${var.resource_prefix}-lb-controller"
  description = "Policy allows to manage ALB and NLB for lb controller for eks ${var.resource_prefix}"
  policy      = data.aws_iam_policy_document.aws_lb.json
}


resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${var.resource_prefix}-lb-controller"
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
            "${var.eks_oidc_provider}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns_attach" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}
