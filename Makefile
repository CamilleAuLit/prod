.DEFAULT_GOAL := generate

CUE_DIR := cue

.PHONY: fmt
fmt:
	@echo "🎨 Formatting..."
	@cd $(CUE_DIR) && cue fmt ./...

.PHONY: vet
vet: 
	@echo "🧐 Vetting..."
	@cd $(CUE_DIR) && cue vet -c ./...

.PHONY: generate
generate: fmt vet 
	@echo "🚀 Generating..."
	@cd $(CUE_DIR) && cue cmd generate $$(find . -name "*.cue" -not -path "*/cue.mod/*")
	@echo "✅ Done!"

.PHONY: clean
clean: 
	@echo "🧹 Cleaning..."
	@rm -f app/vector/agent/vector-agent-app.yaml

.PHONY: help
help: 
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
