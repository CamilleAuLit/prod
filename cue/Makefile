.DEFAULT_GOAL := generate

CUE_FILES=$(shell find cue -name "*.cue")

.PHONY: fmt
fmt:
	@echo "🎨 Formatting..."
	@cue fmt ./cue/...

.PHONY: generate
generate: fmt
	@echo "🚀 Generating..."
	@cd cue && cue cmd generate ./...

.PHONY: clean
clean:
	@echo "🧹 Cleaning..."
	@rm -f app/vector/agent/vector-agent-app.yaml
