####### delete kafkatopic ######
export namespaces=$(kubectl get kafkatopics -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
for ns in $namespaces
do
    kubectl delete kafkatopics -n $ns $(kubectl get kafkatopics -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
done

####### delete connectors ######
export namespaces=$(kubectl get connectors -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
for ns in $namespaces
do
    kubectl delete connectors -n $ns $(kubectl get connectors -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
done

####### delete connectors ######
export namespaces=$(kubectl get ksqldb -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
for ns in $namespaces
do
    kubectl delete ksqldb -n $ns $(kubectl get ksqldb -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
done

####### delete connectors ######
export namespaces=$(kubectl get schemaregistry -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
for ns in $namespaces
do
    kubectl delete schemaregistry -n $ns $(kubectl get schemaregistry -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
done

####### delete kafkarestproxy ######
export namespaces=$(kubectl get kafkarestproxy -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
for ns in $namespaces
do
    kubectl delete kafkarestproxy -n $ns $(kubectl get kafkarestproxy -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
done

####### delete kafka ######
export namespaces=$(kubectl get kafka -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
for ns in $namespaces
do
    kubectl delete kafka -n $ns $(kubectl get kafka -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
done

####### delete zookeeper ######
export namespaces=$(kubectl get zookeeper -A -o "jsonpath={.items[*].metadata}" | jq -r .namespace | sort | uniq)
for ns in $namespaces
do
    kubectl delete zookeeper -n $ns $(kubectl get zookeeper -n $ns -o "jsonpath={.items[*].metadata}" | jq -r .name)
done



