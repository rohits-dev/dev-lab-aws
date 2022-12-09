locals {
  amd_instance_types = ["t3a.2xlarge", "t3.2xlarge", "t2.2xlarge",
  "m6i.2xlarge", "m5.2xlarge", "m5a.2xlarge", ]
  arm_instance_types       = ["t4g.2xlarge", "m6g.2xlarge", "c6g.4xlarge", "r6g.xlarge"]
  amd_ami                  = "AL2_x86_64"
  arm_ami                  = "AL2_ARM_64"
  effective_instance_types = var.arm_or_amd == "ARM" ? local.arm_instance_types : local.amd_instance_types
  effective_ami            = var.arm_or_amd == "ARM" ? local.arm_ami : local.amd_ami

}
