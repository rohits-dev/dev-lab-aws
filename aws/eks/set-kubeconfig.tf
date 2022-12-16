


resource "null_resource" "configure_kube_config" {
  #depends_on = [module.eks, module.vpn]
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
  }
}
