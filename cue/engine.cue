package config

import "encoding/yaml"

registry: [string]: {
	name:    string
	folder:  string
	output?: _
	objects?: {[string]: _}
	...
}

files: {
	for appKey, app in registry {

		if app.objects != _|_ {
			for filename, obj in app.objects {
				"app/\(app.name)/\(filename).yaml": {
					content: obj
				}
			}
		}

		if app.output != _|_ {
			"app/\(app.folder)/\(app.name).yaml": {
				content: app.output & {
					spec: source: helm: values: yaml.Marshal(app.helmValues)
				}
			}
		}
	}
}
