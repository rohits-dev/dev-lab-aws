#!/bin/sh
set -euxo pipefail

echo "Creating VPC, EKS and VPN"
terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve
echo "Adding Services onto EKS"
terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" -var="ADD_FLUXCD=true" --auto-approve
echo "Making EKS private for security reason, use VPN to access it"
terraform apply -var="ADD_EKS_PUBLIC_ACCESS=false" -var="ADD_FLUXCD=true" --auto-approve
