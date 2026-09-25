.PHONY: help shell-enter formatter-check formatter-fix linter-check linter-fix flake-check spellchecker-check check fix

help: ## Show this help
	@DESCRIPTION_WIDTH=$$(grep -Eh '^[a-zA-Z0-9.*-]+:.*##' $(MAKEFILE_LIST) | \
	awk -F ':.*##' '{ if (length($$1) > max) max = length($$1) } END { print max }'); \
	grep -Eh '^[a-zA-Z0-9.*-]+:.*##' $(MAKEFILE_LIST) | \
	awk -v width=$$DESCRIPTION_WIDTH 'BEGIN { FS = ":.*##" } { printf "\033[36m%-" width "s\033[0m %s\n", $$1, $$2 }'

shell-enter: ## Enter development shell
	@env -u MAKELEVEL nix develop -c "$$SHELL"

formatter-check: ## Check formatting
	@treefmt --fail-on-change

formatter-fix: ## Fix formatting
	@treefmt

linter-check: ## Check Nix linting
	@statix check
	@deadnix .

linter-fix: ## Fix Nix linting
	@statix fix
	@deadnix --edit .

flake-check: ## Check Nix flake
	@nix flake check

spellchecker-check: ## Check spelling
	@typos .

check: formatter-check linter-check flake-check spellchecker-check ## Run all checks

fix: formatter-fix linter-fix ## Run all fixes
