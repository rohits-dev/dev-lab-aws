locals {
  target_path         = "cluster-resources/operators/"
  target_path_level_0 = "cluster-resources/operators-level-0/"
  target_path_level_1 = "cluster-resources/operators-level-1/"
  flux_target_path    = "cluster-resources/flux/"
  cluster_name        = "${var.RESOURCE_PREFIX}-eks-1"
}
