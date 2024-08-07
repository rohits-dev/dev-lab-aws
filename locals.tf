locals {
  
  target_path_level_0 = "cluster-resources/operators-level-0/"
  target_path_level_1 = "cluster-resources/operators-level-1/"
  target_path_level_2 = "cluster-resources/operators-level-2/"
  resources_level_0   = "cluster-resources/resources-operator-level-0/"
  resources_level_1   = "cluster-resources/resources-operator-level-1/"
  flux_target_path    = "cluster-resources/flux/"
  cluster_name        = "${var.RESOURCE_PREFIX}-eks-1"
}
