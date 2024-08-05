

data "aws_subnets" "private_subnet_a" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "availabilityZone"
    values = ["${var.aws_region}a"]
  }
  filter {
    name   = "tag:Name"
    values = var.private_subnets_name_filter
  }
}

data "aws_subnets" "private_subnet_b" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "availabilityZone"
    values = ["${var.aws_region}b"]
  }
  filter {
    name   = "tag:Name"
    values = var.private_subnets_name_filter
  }
}
data "aws_subnets" "private_subnet_c" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name   = "availabilityZone"
    values = ["${var.aws_region}c"]
  }
  filter {
    name   = "tag:Name"
    values = var.private_subnets_name_filter
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  # version                         = "~> 20.0"
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.30"
  subnet_ids                      = var.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.add_eks_public_access

  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids
  vpc_id                                = var.vpc_id

  cluster_addons = {
    coredns = {
      resolve_conflicts_on_create = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts_on_create = "OVERWRITE"
    }
  }
  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_internal_all = {
      description = "Within VPC to all node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr_block]
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = local.effective_ami
    disk_size      = 100
    instance_types = local.effective_instance_types
    #vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    zone_a = {
      min_size     = 1
      max_size     = 6
      desired_size = 1
      credit_specification = {
        cpu_credits = "standard"
      }
      instance_types = local.effective_instance_types
      subnet_ids     = data.aws_subnets.private_subnet_a.ids
      capacity_type  = "SPOT"
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "TRUE"
      }
    }
    zone_b = {
      min_size     = 0
      max_size     = 6
      desired_size = 0
      credit_specification = {
        cpu_credits = "standard"
      }
      instance_types = local.effective_instance_types
      subnet_ids     = data.aws_subnets.private_subnet_b.ids
      capacity_type  = "SPOT"
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "TRUE"
      }
    }
    zone_c = {
      min_size     = 0
      max_size     = 6
      desired_size = 0
      credit_specification = {
        cpu_credits = "standard"
      }
      instance_types = local.effective_instance_types
      subnet_ids     = data.aws_subnets.private_subnet_c.ids
      capacity_type  = "SPOT"
      labels = {

        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }
      # taints = {
      #   dedicated = {
      #     key    = "dedicated"
      #     value  = "gpuGroup"
      #     effect = "NO_SCHEDULE"
      #   }
      # }
      tags = {
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"             = "TRUE"
      }
    }
  }
  access_entries = var.aws_eks_access_entries

}

module "ebs_csi_iam_eks_role" {
  source                = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name             = "${var.resource_prefix}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_eks_addon" "aws_ebs_csi_driver" {
  depends_on = [
    module.eks
  ]
  cluster_name  = var.cluster_name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.33.0-eksbuild.1"
  # Remove the deprecated "resolve_conflicts" attribute
  # resolve_conflicts        = "OVERWRITE"
  service_account_role_arn = module.ebs_csi_iam_eks_role.iam_role_arn
}

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name

# }

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}
