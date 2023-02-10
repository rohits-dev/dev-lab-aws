locals {
  file_header_not_safe = <<EOT
    #############################################################################
    #############################################################################
    ######### Managed by Terraform, not safe to change ##########################
    #############################################################################
    #############################################################################
    EOT
   file_header_safe = <<EOT
    #############################################################################
    #############################################################################
    ######### Managed by Terraform, safe to change ##########################
    #############################################################################
    #############################################################################
    EOT

}