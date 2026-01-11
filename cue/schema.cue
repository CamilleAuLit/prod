package config

#VectorApp: {
	appName=name: string
	folder:       string
	role:         "Agent" | "Stateless-Aggregator"
	config:       _

	helmValues: {
		customConfig: config
	}

	output: {
		apiVersion: "argoproj.io/v1alpha1"
		kind:       "Application"
		metadata: {
			name:      appName
			namespace: "argocd"
		}
		spec: {
			project: "default"
			source: {
				repoURL:        "https://github.com/CamilleAuLit/prod"
				chart:          "vector"
				targetRevision: "0.38.0"
				helm: {}
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
