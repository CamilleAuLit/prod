package config

#VectorApp: {
	appName=name: string
	folder:       string
	AppRole=role: "Agent" | "Stateless-Aggregator"
	config:       _

	helmValues: {
		role:         AppRole
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
				repoURL:        "https://helm.vector.dev"
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

#Namespace: {
	apiVersion: "v1"
	kind:       "Namespace"
	metadata: name: string
}

#Pvc: {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		name:      string
		namespace: string
	}
	spec: {
		accessModes: [{string | *"ReadWriteOnce"}]
		resources: requests: storage: string | "1Gi"
	}
}

#Vaultwarden: {
	apiVersion: "apps/v1"
	kind:       "Deployment"
	metadata: {
		name:      "vaultwarden"
		namespace: "vaultwarden"
		labels: app: "vaultwarden"
	}
	spec: {
		replicas: 1
		selector: matchLabels: app: "vaultwarden"
		strategy: type: "Recreate"
		template: {
			metadata: labels: app: "vaultwarden"
			spec: {
				containers: [{
					name:            "vaultwarden"
					image:           "vaultwarden/server:latest"
					imagePullPolicy: "Always"
					ports: [{
						containerPort: 80
						name:          "http"
					}]
					env: [{
						name:  "SIGNUPS_ALLOWED"
						value: "true"
					}]
					volumeMounts: [{
						name:      string
						mountPath: "/data"
					}]
					readinessProbe: httpGet: {
						path: "/"
						port: 80
					}
					initialDelaySeconds: 10
					periodSeconds:       5
					livenessProbe: httpGet: {
						path:                "/"
						port:                80
						initialDelaySeconds: 10
						periodSeconds:       5
					}
				}]
				volumes: [{
					name: string
					persistentVolumeClaim: claimName: "vaultwarden-data"
				}]
			}
		}
	}
}

#Service: {
	apiVersion: "v1"
	kind:       "Service"
	metadata: {
		name:      string
		namespace: string
	}
	spec: {
		selector: app: string
		ports: [{
			name:       string
			port:       int
			targetPort: int
			protocol:   string | *"TCP"
		}]
	}
}

#Ingress: {
	apiVersion: "networking.k8s.io/v1"
	kind:       "Ingress"
	metadata: {
		name:      string
		namespace: string
		annotations: {
			"nginx.ingress.kubernetes.io/force-ssl-redirect": "true"
			"cert-manager.io/cluster-issuer":                 "letsencrypt-prod"
		}
	}
	spec: {
		ingressClassName: "nginx"
		rules: [{
			host: string
			http: {
				paths: [{
					path:     "/"
					pathType: "Prefix"
					backend: service: {
						name: string
						port: number: 80
					}
				}]
			}
		}]
		tls: [{
			hosts: [{string}]
			secretName: string
		}]
	}
}
