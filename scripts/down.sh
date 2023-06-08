set -euo pipefail
SECONDS=0
source ./scripts/bash_fn.sh



has_fluxcd=$(terraform output has_fluxcd)
eks_has_public_access=$(terraform output eks_has_public_access)

if [[ $has_fluxcd == "true" ]];  then
    echo "stage 1 - Opening public access to EKS"
    terraform apply --target='module.eks.module.eks.aws_eks_cluster.this[0]' -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve

    eks_cluster_name=$(terraform output -json | jq -r '.eks_cluster_name.value | values')
    aws_region=$(terraform output -json | jq -r '.aws_region.value | values')
    aws eks update-kubeconfig --region $aws_region --name $eks_cluster_name

    echo "stage 2 - delete all confluent resources"
    ./scripts/cleanup-kafka.sh
    
    echo "Stage 3 - delete services in EKS deployed via Flux"
    flux suspend kustomization flux-system
    set +e
    flux suspend kustomization operators-level-1
    flux delete kustomization operators -s
    sleep 30
    flux delete kustomization operators-level-1 -s
    
    sleep 10
    kubectl delete validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg
    kubectl delete mutatingwebhookconfiguration kyverno-resource-mutating-webhook-cfg
    set -e
    sleep 10
    ####### delete pvc ######
    delete_all_resources 'pvc'
    
    ####### delete pv ######
    delete_all_resources 'pv'

    echo "Stage 4 - Deleting services deployed in EKS"
    terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve
fi

echo "Final Stage 5 - delete vpc, eks, vpn etc"
terraform destroy --auto-approve

echo "Successfully completed !"

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds to complete the script!"