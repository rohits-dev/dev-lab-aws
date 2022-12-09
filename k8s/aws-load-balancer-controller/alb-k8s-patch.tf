

# GitHub
data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

data "template_file" "release_patch" {
  template = file("${path.module}/k8s_patches/release-patch.yaml")
  vars = {
    eks_cluster_name = var.eks_cluster_name
    owner_name       = var.github_owner
    owner_email      = var.owner_email
  }
}

resource "github_repository_file" "release_patch" {
  repository          = data.github_repository.main.name
  file                = "${var.target_path}aws-load-balancer-controller/release-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.release_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}
