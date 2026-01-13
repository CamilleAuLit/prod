package config

import (
	"tool/file"
	"encoding/yaml"
	"tool/cli"
	"path"
	"tool/exec"
)

command: generate: {
	task: start: cli.Print & {
		text: "🔄 Début de la génération de \(len(files)) fichiers..."
	}

	for key, f in files {

		let finalPath = path.Join(["..", key])
		let dirPath = path.Dir(finalPath)

		"mkdir-\(key)": exec.Run & {
			cmd: ["mkdir", "-p", dirPath]
			stdout: string
		}

		"write-\(key)": file.Create & {
			$after: ["mkdir-\(key)"]

			filename: finalPath
			contents: yaml.Marshal(f.content)
		}
	}

	task: end: cli.Print & {
		$after: [for k, _ in files {"write-\(k)"}]
		text: "✅ Génération terminée avec succès."
	}
}
