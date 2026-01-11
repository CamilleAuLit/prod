package config

import (
	"tool/file"
	"encoding/yaml"
	"tool/cli"
	"path"
)

command: generate: {
	task: start: cli.Print & {
		text: "🔄 Début de la génération de \(len(files)) fichiers..."
	}

	for key, f in files {
		"write-\(key)": file.Create & {
			filename: path.Join(["..", f.path])

			contents: yaml.Marshal(f.content)
		}
	}

	task: end: cli.Print & {
		text: "✅ Génération terminée."
	}
}
