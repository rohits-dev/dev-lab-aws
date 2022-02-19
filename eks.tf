module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "18.7.2"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.20"
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  vpc_id = module.vpc.vpc_id

  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }


  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    disk_size      = 50
    instance_types = ["t3.small", "t3.large", "m5.large"]
    #vpc_security_group_ids = [aws_security_group.additional.id]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "DEV"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }
      tags = {
        ExtraTag = "example"
      }
    }
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
