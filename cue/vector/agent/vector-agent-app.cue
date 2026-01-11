package config

import "encoding/yaml"

// On ajoute notre fichier vector à la liste globale 'files'
files: "app/vector/agent/vector-agent-app.yaml": {

	// Le contenu de ton Application ArgoCD
	content: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "Application"
		metadata: {
			name:      "vector-agent"
			namespace: "argocd"
		}
		spec: {
			project: "default"
			source: {
				repoURL:        "https://helm.vector.dev"
				chart:          "vector"
				targetRevision: "0.38.0"
				helm: {
					// On convertit la config Vector en string YAML ici
					values: yaml.Marshal(_vectorValues)
				}
			}
			destination: {
				server:    "https://kubernetes.default.svc"
				namespace: "monitoring"
			}
			syncPolicy: {
				automated: {
					prune:    true
					selfHeal: true
				}
			}
		}
	}
}

// --- Ta config Vector (inchangée, mais rangée en bas) ---
_vectorValues: {
	role: "Agent"
	customConfig: {
		data_dir: "/vector-data-dir"
		api: {
			enabled: true
			address: "0.0.0.0:8686"
		}
		sources: {
			k8s_logs: {
				type:           "kubernetes_logs"
				self_node_name: "${VECTOR_SELF_NODE_NAME}"
			}
		}
		sinks: {
			to_kafka: {
				type: "kafka"
				inputs: ["k8s_logs"]
				bootstrap_servers: "prod-cluster-kafka-bootstrap.kafka.svc:9092"
				topic:             "k3s-logs"
				encoding: codec: "json"
			}
		}
	}
}
