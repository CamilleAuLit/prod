package k8s

// Définition simplifiée d'un objet Kubernetes
#Metadata: {
	name:      string
	namespace: string | *"kafka" // Par défaut "kafka"
}

// Le schéma de contrainte pour nos Pods Kafka (Le secret sauce)
#AffinitySpec: {
	nodeSelector: {
		"type": "perf" // OBLIGATOIRE : On veut le i7 !
	}
}

// Notre définition de Cluster Kafka Strimzi
#KafkaCluster: {
	apiVersion: "kafka.strimzi.io/v1beta2"
	kind:       "Kafka"
	metadata:   #Metadata
	spec: {
		kafka: {
			version:  "3.7.0"
			replicas: 1
			listeners: [
				{name: "plain", port: 9092, type: "internal", tls: false},
				{name: "external", port: 9094, type: "nodeport", tls: false},
			]
			// On injecte la contrainte ici
			template: pod: spec: #AffinitySpec
			storage: {
				type: "jbod"
				volumes: [{
					id:          0
					type:        "persistent-claim"
					size:        "20Gi"
					deleteClaim: false
				}]
			}
			config: {
				"offsets.topic.replication.factor":         1
				"transaction.state.log.replication.factor": 1
				"min.insync.replicas":                      1
			}
		}
		zookeeper: {
			replicas: 1
			// On injecte la contrainte ici aussi
			template: pod: spec: #AffinitySpec
			storage: {
				type: "persistent-claim"
				size: "5Gi"
				deleteClaim: false
			}
		}
		entityOperator: {
			topicOperator: {}
			userOperator: {}
		}
	}
}

// L'instance réelle
kafkaProd: #KafkaCluster & {
	metadata: name: "mon-gros-kafka"
}
