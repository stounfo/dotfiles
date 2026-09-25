.PHONY: help shell-enter formatter-check formatter-fix linter-check linter-fix flake-check spellchecker-check check fix build

help: ## Show this help
	@DESCRIPTION_WIDTH=$$(grep -Eh '^[a-zA-Z0-9.*-]+:.*##' $(MAKEFILE_LIST) | \
	awk -F ':.*##' '{ if (length($$1) > max) max = length($$1) } END { print max }'); \
	grep -Eh '^[a-zA-Z0-9.*-]+:.*##' $(MAKEFILE_LIST) | \
	awk -v width=$$DESCRIPTION_WIDTH 'BEGIN { FS = ":.*##" } { printf "\033[36m%-" width "s\033[0m %s\n", $$1, $$2 }'

switch: ## Build and activate host (TARGET=nixos-1|darwin-1)
	@test -n "$(TARGET)" || (echo "TARGET is required"; exit 1)

	@case "$(TARGET)" in \
		nixos-*) \
			sudo nixos-rebuild switch --flake "path:.#$(TARGET)" ;; \
		darwin-*) \
			sudo darwin-rebuild switch --flake "path:.#$(TARGET)" ;; \
		*) \
			echo "TARGET must be nixos-* or darwin-*"; \
			exit 1 ;; \
	esac

build: ## Build host (TARGET=nixos-1|darwin-1)
	@test -n "$(TARGET)" || (echo "TARGET is required"; exit 1)

	@case "$(TARGET)" in \
		nixos-*) \
			if [ "$(SKIP_ASAHI_FIRMWARE)" = "1" ]; then \
				nix build --impure --expr 'let flake = builtins.getFlake (toString ./.); system = flake.nixosConfigurations."$(TARGET)".extendModules { modules = [ ./overrides/skip-asahi-firmware.nix ]; }; in system.config.system.build.toplevel' --no-link; \
			else \
				nix build ".#nixosConfigurations.$(TARGET).config.system.build.toplevel" --no-link; \
			fi ;; \
		darwin-*) \
			nix build ".#darwinConfigurations.$(TARGET).system" --no-link ;; \
		*) \
			echo "TARGET must be nixos-* or darwin-*"; \
			exit 1 ;; \
	esac

shell-enter: ## Enter development shell
	@env -u MAKELEVEL nix develop -c "$$SHELL"

check: formatter-check linter-check flake-check spellchecker-check ## Run all checks

fix: formatter-fix linter-fix ## Run all fixes

formatter-check: ## Check formatting
	@nix develop -c treefmt --fail-on-change

formatter-fix: ## Fix formatting
	@nix develop -c treefmt

linter-check: ## Check Nix linting
	@nix develop -c statix check
	@nix develop -c deadnix .

linter-fix: ## Fix Nix linting
	@nix develop -c statix fix
	@nix develop -c deadnix --edit .

flake-check: ## Check Nix flake
	@nix flake check --all-systems

spellchecker-check: ## Check spelling
	@nix develop -c typos .
