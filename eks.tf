data "aws_subnets" "private_subnet_a" {
  depends_on = [
    module.vpc
  ]
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "availabilityZone"
    values = ["${var.AWS_REGION}a"]
  }
  filter {
    name   = "tag:Name"
    values = var.PRIVATE_SUBNETS_NAME_FILTER
  }
}
data "aws_subnets" "private_subnet_b" {
  depends_on = [
    module.vpc
  ]
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "availabilityZone"
    values = ["${var.AWS_REGION}b"]
  }
  filter {
    name   = "tag:Name"
    values = var.PRIVATE_SUBNETS_NAME_FILTER
  }
}
data "aws_subnets" "private_subnet_c" {
  depends_on = [
    module.vpc
  ]
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "availabilityZone"
    values = ["${var.AWS_REGION}c"]
  }
  filter {
    name   = "tag:Name"
    values = var.PRIVATE_SUBNETS_NAME_FILTER
  }
}

module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "~> 18.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.22"
  subnet_ids                      = local.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.ADD_EKS_PUBLIC_ACCESS

  cluster_additional_security_group_ids = [module.vpn.vpn_security_group_id]
  vpc_id                                = local.vpc_id

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
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
      cidr_blocks = [local.vpc_cidr_block]
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
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["t3a.2xlarge"]
    #vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {

    dedicated_all_zone = {
      min_size     = 0
      max_size     = 6
      desired_size = 1
      credit_specification = {
        cpu_credits = "standard"
      }
      instance_types = ["t3a.2xlarge"]
      subnet_ids = concat(data.aws_subnets.private_subnet_a.ids,
        data.aws_subnets.private_subnet_b.ids,
        data.aws_subnets.private_subnet_c.ids
      )
      capacity_type = "ON_DEMAND"
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = "TRUE"
      }
    }
    zone_a = {
      min_size     = 0
      max_size     = 6
      desired_size = 1
      credit_specification = {
        cpu_credits = "standard"
      }
      instance_types = ["t3a.2xlarge"]
      subnet_ids     = data.aws_subnets.private_subnet_a.ids
      capacity_type  = "SPOT"
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = "TRUE"
      }
    }
    zone_b = {
      min_size     = 0
      max_size     = 6
      desired_size = 1
      credit_specification = {
        cpu_credits = "standard"
      }
      instance_types = ["t3a.2xlarge"]
      subnet_ids     = data.aws_subnets.private_subnet_b.ids
      capacity_type  = "SPOT"
      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      tags = {
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = "TRUE"
      }
    }
    zone_c = {
      min_size     = 0
      max_size     = 6
      desired_size = 1
      credit_specification = {
        cpu_credits = "standard"
      }
      instance_types = ["t3a.2xlarge"]
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
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        "k8s.io/cluster-autoscaler/enabled"               = "TRUE"
      }
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = var.ADD_FLUXCD

  aws_auth_roles = var.AWS_AUTH_ROLES
  aws_auth_users = var.AWS_AUTH_USERS
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id

}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id

}
