data "template_file" "vault_patch" {
  template = file("${path.module}/k8s_patches/vault-release-patch.yaml")
  vars = {
    vault_auto_unseal_kms_id = aws_kms_key.vault.key_id
    vault_role_arn           = aws_iam_role.vault.arn
    resource_prefix          = var.resource_prefix
    aws_region               = var.aws_region
  }
}

data "template_file" "vault_init_job_patch" {
  template = file("${path.module}/k8s_patches/vault-init-job-patch.yaml")
  vars = {
    s3_bucket  = local.vault_s3_bucket_name
    aws_region = var.aws_region
  }
}

resource "github_repository_file" "vault_patch" {
  repository          = var.repository_name
  file                = "${var.target_path}vault/release/vault-release-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.vault_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}

resource "github_repository_file" "vault_init_job_patch" {
  repository          = var.repository_name
  file                = "${var.target_path}vault/release/vault-init-job-patch.yaml"
  content             = "${local.file_header_not_safe}${data.template_file.vault_init_job_patch.rendered}"
  branch              = var.branch
  overwrite_on_create = true
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }

  provisioner "local-exec" {
    when       = destroy
    command    = <<EOT
    helm uninstall vault -nvault
    kubectl delete pvc data-vault-0 data-vault-1 data-vault-2 audit-vault-0 audit-vault-1 audit-vault-2 -nvault
    kubectl get -nvault helmrelease vault -o  json \
      | tr -d "\n" | sed "s/\"finalizers.fluxcd.io\"//g" \
      | kubectl -nvault replace --raw /apis/helm.toolkit.fluxcd.io/v2beta1/namespaces/vault/helmreleases/vault -f -
    kubectl delete --all helmrelease -nvault

    EOT
    on_failure = continue
  }

}

resource "kubernetes_secret" "vault_tls_ca_crt" {
  depends_on = [kubernetes_namespace.vault]

  metadata {
    name      = "tls-ca"
    namespace = "vault"
  }

  data = {
    "tls.crt" = var.root_ca_crt
    "tls.key" = var.root_ca_key
  }
  type = "kubernetes.io/tls"
}

resource "kubernetes_secret" "vault_tls_server_crt" {
  depends_on = [kubernetes_namespace.vault]

  metadata {
    name      = "tls-server"
    namespace = "vault"
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.vault_certificate.cert_pem
    "tls.key" = tls_private_key.vault_certificate.private_key_pem
  }
  type = "kubernetes.io/tls"
}
