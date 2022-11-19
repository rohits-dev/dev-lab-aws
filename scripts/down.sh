set -euo pipefail
source ./scripts/bash_fn.sh



has_fluxcd=$(terraform output has_fluxcd)
eks_has_public_access=$(terraform output eks_has_public_access)

if [[ $has_fluxcd == "true" ]];  then
    echo "stage 1 - Opening public access to EKS"
    terraform apply --target='module.eks.aws_eks_cluster.this[0]' -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve

    echo "stage 2 - delete all confluent resources"
    ./scripts/cleanup-kafka.sh
    
    echo "Stage 3 - delete services in EKS"
    flux suspend kustomization flux-system
    set +e
    flux delete kustomization operators -s
    sleep 3
    kubectl delete validatingwebhookconfiguration kyverno-resource-validating-webhook-cfg
    kubectl delete mutatingwebhookconfiguration kyverno-resource-mutating-webhook-cfg
    set -e
    ####### delete pvc ######
    delete_all_resources 'pvc'
    
    ####### delete pv ######
    delete_all_resources 'pv'

    echo "stage 3 - Deleting services deployed in EKS"
    terraform apply -var="ADD_EKS_PUBLIC_ACCESS=true" --auto-approve
fi

echo "delete vpc, eks, vpn etc"
terraform destroy --auto-approve

echo "Successfully completed !"