
delete_all_resources(){
    resource_kind=$1
    echo "Deleting all $resource_kind"
    export namespaces=$(kubectl get $resource_kind -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
    for ns in $namespaces
    do
        echo "Deleting all $resource_kind in namespace $ns"
        kubectl delete $resource_kind -n $ns $(kubectl get $resource_kind -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
    done
}