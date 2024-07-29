eu_cluster_id=$(kubectl exec kafka-eu-0 -c kafka-eu -- bash -c "curl http://kafka-eu:8090/kafka/v3/clusters --silent" | jq -r '.data[0].cluster_id')

cn_cluster_id=$(kubectl exec kafka-cn-0 -c kafka-cn -- bash -c "curl http://kafka-cn:8090/kafka/v3/clusters --silent" | jq -r '.data[0].cluster_id')