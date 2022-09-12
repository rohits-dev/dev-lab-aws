locals {
  namespace_name       = "kube-system"
  service_account_name = "aws-load-balancer-controller"

  known_hosts          = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  file_header_not_safe = <<EOT
    #############################################################################
    #############################################################################
    ######### Managed by Terraform, not safe to change ##########################
    #############################################################################
    #############################################################################
    EOT
  file_header_safe     = <<EOT
    #############################################################################
    #############################################################################
    ######### Managed by Terraform, safe to change ##########################
    #############################################################################
    #############################################################################
    EOT
}
