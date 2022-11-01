set -euxo pipefail
echo "Opening public access to EKS"
terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" -var="ADD_FLUXCD=true" --auto-approve
echo "Deleting services deployed in EKS"
terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve
echo "Deleting EKS and VPCs"
terraform destroy --auto-approve