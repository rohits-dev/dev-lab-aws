#!/bin/sh
set -euo pipefail
SECONDS=0
echo "Initialize terraform..."
terraform init --upgrade

has_fluxcd=$(terraform output has_fluxcd)
eks_has_public_access=$(terraform output eks_has_public_access)

if [[ $has_fluxcd != "true"  ]];  then
    echo "stage 1 - Creating VPC, EKS and VPN"
    terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve
fi
echo "stage 2 - Opening public access to EKS"
terraform apply --target='module.eks.module.eks.aws_eks_cluster.this[0]' -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve

echo "stage 3 - Adding Services onto EKS"
terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" -var="ADD_FLUXCD=true" --auto-approve

# echo "stage 4 - Making EKS private for security reason, use VPN to access it"
# terraform apply -var="ADD_EKS_PUBLIC_ACCESS=false" -var="ADD_FLUXCD=true" --auto-approve

echo "Successfully completed !"

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds to complete the script!"