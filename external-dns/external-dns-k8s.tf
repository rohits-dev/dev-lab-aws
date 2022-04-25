data "template_file" "external_dns_release_patch" {
  template = "${file("${path.module}/k8s_patches/external-dns-patch.yaml")}"
  vars = {
    resource_prefix = var.resource_prefix
    external_dns_iam_role_arn = aws_iam_role.external_dns.arn
  }
}

# GitHub
data "github_repository" "main" {
  full_name  = "${var.github_owner}/${var.repository_name}"
}

resource "github_repository_file" "external_dns_release_patch" {
  repository          = data.github_repository.main.name
  file                = "${var.target_path}external-dns/release/external-dns-release-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.external_dns_release_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}