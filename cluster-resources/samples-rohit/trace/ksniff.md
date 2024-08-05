kubectl sniff perf-producer-0 -p  -o - | tshark -N n -Tfields  -Y 'kafka' -w test.pcap -e frame.time -e ip.src_host -e ip.dst_host -e kafka -e kafka.partition_id -e kafka.api_key -r -

kubectl sniff perf-consumer-0 -p  -o - | tshark -N n -Tfields  -Y 'kafka' -w test.pcap -e frame.time -e ip.src_host -e ip.dst_host -e kafka -e kafka.partition_id -e kafka.api_key -r -

kafka-run-class kafka.tools.EndToEndLatency kafka:9071 e2e 10000 all 1024

kafka-producer-perf-test --throughput "2"  --payload-file /mnt/payload/payload.json --num-records "100" --print-metrics --producer.config /mnt/config/client.config --topic perf-test-1 --print-metrics
