


resource "null_resource" "configure_kube_config" {
  depends_on = [module.eks, module.vpn]
  #count = var.ADD_FLUXCD ? 1: 0
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.AWS_REGION} --name ${var.RESOURCE_PREFIX}-eks-1"
  }
}
