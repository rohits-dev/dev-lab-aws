

# GitHub
data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

data "template_file" "prometheus_release_patch" {
  template = file("${path.module}/k8s_patches/release-patch.yaml")
  vars = {
    resource_prefix = var.resource_prefix
  }
}

resource "github_repository_file" "prometheus_release_patch" {
  repository          = data.github_repository.main.name
  file                = "${var.target_path}prometheus/release-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.prometheus_release_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}
