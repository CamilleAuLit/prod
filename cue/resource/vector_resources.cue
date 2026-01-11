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
		config: {}
	}

	"vector-aggregator": #VectorApp & {
		name:   "vector-aggregator"
		folder: "shipper"
		role:   "Stateless-Aggregator"
		config: {}
	}
}
