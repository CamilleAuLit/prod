package config

registry: {
	"vaultwarden": {
		name:   "vaultwarden2"
		folder: "security"

		objects: {

			namespace: #Namespace & {
				metadata: name: "vaultwarden"
			}

			pvc: #Pvc & {
				metadata: {name: "vaultwarden-data", namespace: "vaultwarden"}
				spec: resources: requests: storage: "1Gi"
			}

			service: #Service & {
				metadata: {name: "vaultwarden", namespace: "vaultwarden"}
				spec: {
					selector: app: "vaultwarden"
					ports: [{port: 80, targetPort: 80, name: "http"}]
				}
			}

			deployment: #Vaultwarden & {
				metadata: {
					name: "vaultwarden", namespace: "vaultwarden"
					labels: app: "vaultwarden"
				}
				spec: {
					selector: matchLabels: app: "vaultwarden"
					template: {
						metadata: labels: app: "vaultwarden"
						spec: {
							containers: [{
								name:  "vaultwarden"
								image: "vaultwarden/server:latest"
								env: [{name: "SIGNUPS_ALLOWED", value: "true"}]
								ports: [{containerPort: 80}]
								volumeMounts: [{name: "data", mountPath: "/data"}]
							}]
							volumes: [{
								name: "data"
								persistentVolumeClaim: claimName: "vaultwarden-data"
							}]
						}
					}
				}
			}

			ingress: #Ingress & {
				metadata: {
					name: "vaultwarden", namespace: "vaultwarden"
					annotations: {"cert-manager.io/cluster-issuer": "letsencrypt-prod"}
				}
				spec: {
					className: "nginx"
					rules: [{
						host: "vaultwarden.yukino.li"
						http: paths: [{
							path: "/", pathType: "Prefix"
							backend: service: {name: "vaultwarden", port: number: 80}
						}]
					}]
					tls: [{
						hosts: ["vaultwarden.yukino.li"], secretName: "vaultwarden-tls"
					}]
				}
			}
		}
	}
}
