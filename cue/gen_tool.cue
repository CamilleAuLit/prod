package config

import (
	"tool/file"
	"encoding/yaml"
	"tool/cli"
)

command: generate: {
	// Etape 1 : On informe l'utilisateur
	task: start: cli.Print & {
		text: "🔄 Début de la génération de \(len(files)) fichiers..."
	}

	// Etape 2 : La boucle magique
	// Pour chaque élément dans la liste 'files', on crée une tâche d'écriture
	for key, f in files {
		"write-\(key)": file.Create & {
			filename: f.path
			// On transforme l'objet 'content' en YAML final
			contents: yaml.Marshal(f.content)
		}
	}
	
	// Etape 3 : Confirmation
	task: end: cli.Print & {
		text: "✅ Génération terminée."
	}
}
