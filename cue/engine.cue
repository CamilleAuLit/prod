package config

import "encoding/yaml"

registry: [string]: {
	name:       string
	folder:     string
	helmValues: _
	output:     _
	...
}

files: {
	for key, app in registry {
		"app/vector/\(app.folder)/\(app.name).yaml": {
			content: app.output & {
				spec: source: helm: values: yaml.Marshal(app.helmValues)
			}
		}
	}
}
