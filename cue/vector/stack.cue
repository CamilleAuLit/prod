package config

registry: {

	"vector-agent": #VectorApp & {
		name:   "vector-agent"
		folder: "agent"
		role:   "Agent"
		config: {
			data_dir: "/vector-data-dir"
			api: {enabled: true, address: "0.0.0.0:8686"}

			sources: k8s_logs: {
				type:           "kubernetes_logs"
				self_node_name: "${VECTOR_SELF_NODE_NAME}"
			}

			sinks: to_kafka: {
				type: "kafka"
				inputs: ["k8s_logs"]
				bootstrap_servers: "prod-cluster-kafka-bootstrap.kafka.svc:9092"
				topic:             "k3s-logs"
				encoding: codec: "json"
			}
		}
	}

	"vector-ingest": #VectorApp & {
		name:   "vector-ingest"
		folder: "ingestor"
		role:   "Stateless-Aggregator"
		config: {
			api: {enabled: true, address: "0.0.0.0:8686"}

			sources: rabbitmq_source: {
				type:              "amqp"
				connection_string: "amqp://admin:1234@10.0.0.199:5672/%2f"
				queue:             "esp32-logs"
			}

			sinks: kafka_sink: {
				type: "kafka"
				inputs: ["rabbitmq_source"]
				bootstrap_servers: "prod-cluster-kafka-bootstrap.kafka.svc:9092"
				topic:             "esp32-stream"
				encoding: codec: "json"
			}
		}
	}

	"vector-aggregator": #VectorApp & {
		name:   "vector-aggregator"
		folder: "shipper"
		role:   "Stateless-Aggregator"
		config: {
			data_dir: "/vector-data-dir"
			api: {enabled: true, address: "0.0.0.0:8686"}

			sources: kafka_source: {
				type:              "kafka"
				bootstrap_servers: "prod-cluster-kafka-bootstrap.kafka.svc:9092"
				topics: ["k3s-logs", "esp32-stream"]
				group_id: "vector-k8s-group"
				decoding: codec: "json"
			}

			transforms: fix_iot_labels: {
				type: "remap"
				inputs: ["kafka_source"]
				source: """
					   if .kubernetes == null {
					    .kubernetes = {}
					   }
					  .kubernetes.pod_namespace = .kubernetes.pod_namespace || "monitoring"
					  .kubernetes.pod_name = .kubernetes.pod_name || "esp32-device"
					"""
			}

			sinks: loki_sink: {
				type: "loki"
				inputs: ["fix_iot_labels"]
				endpoint: "http://loki.monitoring.svc:3100"
				encoding: codec: "json"
				labels: {
					source:    "kafka-vector"
					namespace: "{{ kubernetes.pod_namespace }}"
					pod:       "{{ kubernetes.pod_name }}"
				}
			}
		}
	}
}
