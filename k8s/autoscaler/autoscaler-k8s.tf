data "template_file" "autoscaler_release_patch" {
  template = file("${path.module}/k8s_patches/autoscaler-patch.yaml")
  vars = {
    resource_prefix         = var.resource_prefix
    autoscaler_iam_role_arn = aws_iam_role.cluster_autoscaler.arn
    aws_region              = var.aws_region
  }
}



resource "github_repository_file" "autoscaler_release_patch" {
  repository          = var.repository_name
  file                = "${var.target_path}autoscaler/release/autoscaler-release-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.autoscaler_release_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}
