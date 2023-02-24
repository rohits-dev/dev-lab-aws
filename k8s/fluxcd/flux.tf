
#SSH


resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Flux
data "flux_install" "main" {
  target_path = var.target_path
}

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "ssh://git@github.com/${var.github_owner}/${var.repository_name}.git"
  branch      = var.branch
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [
      metadata[0].labels,
    ]
  }
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content if v.data.kind != "namespace" }
  yaml_body  = each.value
  depends_on = [kubernetes_namespace.flux_system]
}

resource "kubectl_manifest" "sync" {
  for_each   = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body  = each.value
  depends_on = [kubernetes_namespace.flux_system]
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install, kubernetes_namespace.flux_system]

  metadata {
    name      = data.flux_sync.main.secret
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

# GitHub
data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

resource "github_repository_deploy_key" "main" {
  title      = "staging-cluster"
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install" {
  repository = data.github_repository.main.name
  file       = data.flux_install.main.path
  content    = "${local.file_header_not_safe}${data.flux_install.main.content}"
  branch     = var.branch
}

resource "github_repository_file" "sync" {
  repository = data.github_repository.main.name
  file       = data.flux_sync.main.path
  content    = "${local.file_header_not_safe}${data.flux_sync.main.content}"
  branch     = var.branch
}

resource "github_repository_file" "kustomize" {
  repository          = data.github_repository.main.name
  file                = data.flux_sync.main.kustomize_path
  content             = "${local.file_header_safe}${data.flux_sync.main.kustomize_content}"
  branch              = var.branch
  overwrite_on_create = false

  lifecycle {
    ignore_changes = all
    # prevent_destroy = true
  }
}

# #Customize

# locals {
#   # 'Small patches that do one thing are recommended'
#   #   - https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/#customizing
#   patches = {
#     psp  = file("./psp-patch.yaml")
#     sops = <<EOT
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: kustomize-controller
#   namespace: flux-system
#   annotations:
#     eks.amazonaws.com/role-arn: rohit
# EOT
#   }
#   repository_name = "dev-lab-k8s-aws"
# }

# data "flux_sync" "main" {
#   target_path = var.target_path
#   url         = var.clone_url
#   patch_names = keys(local.patches)
#   branch = "tf-test"
# }

# # Create kustomize.yaml
# resource "github_repository_file" "kustomize" {
#   repository          = local.repository_name
#   file                = data.flux_sync.main.kustomize_path
#   content             = data.flux_sync.main.kustomize_content
#   branch              = "tf-test"
#   overwrite_on_create = true
# }

# resource "github_repository_file" "patches" {
#   #  `patch_file_paths` is a map keyed by the keys of `flux_sync.main`
#   #  whose values are the paths where the patch files should be installed.
#   for_each   = data.flux_sync.main.patch_file_paths

#   repository = local.repository_name
#   file       = each.value
#   content    = local.patches[each.key] # Get content of our patch files
#   branch     = "tf-test"
# }
