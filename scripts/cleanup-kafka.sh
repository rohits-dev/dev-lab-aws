set -euo pipefail
source ./scripts/bash_fn.sh

####### delete connectors ######
delete_all_resources 'connectors'

####### delete ksqldb ######
delete_all_resources 'ksqldb'

####### delete schemaexporter ######
delete_all_resources 'schemaexporter'

####### delete schemaregistry ######
delete_all_resources 'schemaregistry'

####### delete kafkatopic ######
delete_all_resources 'kafkatopics'

####### delete kafkarestproxy ######
delete_all_resources 'kafkarestproxy'


####### delete cfrb ######
delete_all_resources 'cfrb'

####### delete connect ######
delete_all_resources 'connect'

####### delete controlcenter ######
delete_all_resources 'controlcenter'

####### delete clusterlink ######
delete_all_resources 'clusterlink'


####### delete kafkarestclasses ######
delete_all_resources 'kafkarestclasses'

####### delete kafka ######
delete_all_resources 'kafka'

####### delete zookeeper ######
delete_all_resources 'zookeeper'

delete_all_resources 'kraft'



