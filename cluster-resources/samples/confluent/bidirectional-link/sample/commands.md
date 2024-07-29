```
cat << EOF > /tmp/cl-cn.config
connection.mode=INBOUND
link.mode=BIDIRECTIONAL
EOF

eu_cluster_id=$(kubectl exec kafka-eu-0 -c kafka-eu -- bash -c "curl http://kafka-eu:8090/kafka/v3/clusters --silent" | jq -r '.data[0].cluster_id')

kafka-cluster-links --bootstrap-server kafka-cn.confluent.svc.cluster.local:9071 \
--delete --link bidirectional-link

kafka-cluster-links --bootstrap-server kafka-cn.confluent.svc.cluster.local:9071 \
--create --link bidirectional-link \
--config-file /tmp/cl-cn.config  --cluster-id 73abc9d8-4862-43e9-a1Q #eu cluster id (remote)

cat << EOF > /tmp/cl-eu.config
link.mode=BIDIRECTIONAL
connection.mode=OUTBOUND
remote.link.connection.mode=INBOUND
bootstrap.servers=kafka-cn.confluent.svc.cluster.local:9071

EOF

cat > /tmp/client.config

bootstrap.servers=kafka-eu.kafka2.confluent.svc.cluster.local:9072

kafka-cluster-links --bootstrap-server kafka-eu.confluent.svc.cluster.local:9071 \
--delete --link bidirectional-link

kafka-cluster-links --bootstrap-server kafka-eu.confluent.svc.cluster.local:9071 \
--link bidirectional-link --create \
--config-file /tmp/cl-eu.config  --cluster-id 031928c3-9cb4-42ce-88w  #cn cluster id (remote cluster)

kafka-mirrors --bootstrap-server kafka-cn:9071 --link bidirectional-link --mirror-topic eu-perf-test --create --source-topic eu-perf-test

kafka-mirrors --bootstrap-server kafka-eu:9071 --link bidirectional-link --mirror-topic cn-perf-test --create


```
<!-- 
{"timestamp":"2024-04-25 16:40:04,492","level":"WARN","thread":"kafka-admin-client-thread | cluster-link-eu-cn-link-local-source-conn-admin-5","class":"kafka.utils.Logging","message":"[ClusterLinkOutboundConnectionManager-eu-cn-link-broker-5] Failed to create persistent reverse connectionorg.apache.kafka.common.errors.InvalidRequestException: Incorrect source broker id, expected 3, requested 5
"}
{"timestamp":"2024-04-25 16:40:04,492","level":"WARN","thread":"kafka-admin-client-thread | cluster-link-eu-cn-link-local-source-conn-admin-5","class":"kafka.utils.Logging","message":"[ClusterLinkOutboundConnectionManager-eu-cn-link-broker-5] Connection reversal request to local broker failed forrequestId=-1org.apache.kafka.common.errors.InvalidRequestException: Incorrect source broker id, expected 3, requested 5 -->
