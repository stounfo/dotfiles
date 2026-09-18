.PHONY: help
help: ## Show this help
	@DESCRIPTION_WIDTH=$$(grep -Eh '^[a-zA-Z0-9\._-]+:.*?##' $(MAKEFILE_LIST) | \
		awk -F ':.*?##' '{ if (length($$1) > max) max = length($$1) } END { print max }'); \
	grep -Eh '^[a-zA-Z0-9\._-]+:.*?##' $(MAKEFILE_LIST) | \
	awk -v width=$$DESCRIPTION_WIDTH 'BEGIN { FS = ":.*?##" } { printf "\033[36m%-" width "s\033[0m %s\n", $$1, $$2 }'

all: deps-install-all dots-install ## Install all dependencies and all dotfiles

deps-install-all: deps-install-python deps-install-ansible ## Install all dependencies

PYTHON_VERSION="3.13.1"
deps-install-python: ## Install python to ./tmp directory
	@git clone https://github.com/pyenv/pyenv.git ./tmp/pyenv; \
	./tmp/pyenv/plugins/python-build/bin/python-build $(PYTHON_VERSION) ./tmp;

ANSIBLE_VERSION="11.2.0"
deps-install-ansible: ## Install ansible using python in ./tmp directory
	@./tmp/bin/python -m pip install ansible==${ANSIBLE_VERSION}

DOTS ?= all
SKIP_DOTS ?=
# Select ansible-galaxy and ansible-playbook based on the ANSIBLE_PATH variable
ANSIBLE_PATH ?= auto
dots-install: ## Install dotfiles
	@DOTS="${DOTS}"; \
	SKIP_DOTS="${SKIP_DOTS}"; \
	export PATH="/opt/homebrew/bin:$$PATH" \
	ANSIBLE_PATH="${ANSIBLE_PATH}"; \
	\
	cmd_exists() { \
	    if which "$$1" >/dev/null 2>&1; then \
	        which "$$1"; \
	    elif test -x "$$2"; then \
	        echo "$$2"; \
	    else \
	        echo "none"; \
	    fi; \
	}; \
	if [ "$$ANSIBLE_PATH" = "global" ]; then \
	    ANSIBLE_GALAXY=$$(which ansible-galaxy 2>/dev/null || echo "none"); \
	    ANSIBLE_PLAYBOOK=$$(which ansible-playbook 2>/dev/null || echo "none"); \
	elif [ "$$ANSIBLE_PATH" = "local" ]; then \
		ANSIBLE_GALAXY="./tmp/bin/ansible-galaxy"; \
		ANSIBLE_PLAYBOOK="./tmp/bin/ansible-playbook"; \
		if [ ! -x "$$ANSIBLE_GALAXY" ]; then ANSIBLE_GALAXY="none"; fi; \
		if [ ! -x "$$ANSIBLE_PLAYBOOK" ]; then ANSIBLE_PLAYBOOK="none"; fi; \
	else \
	    ANSIBLE_GALAXY=$$(cmd_exists ansible-galaxy ./tmp/bin/ansible-galaxy); \
	    ANSIBLE_PLAYBOOK=$$(cmd_exists ansible-playbook ./tmp/bin/ansible-playbook); \
	fi; \
	\
	if [ "$$ANSIBLE_GALAXY" = "none" ]; then \
	    echo "Error: ansible-galaxy is not installed or not found in specified path" >&2; \
	    exit 1; \
	fi; \
	if [ "$$ANSIBLE_PLAYBOOK" = "none" ]; then \
	    echo "Error: ansible-playbook is not installed or not found in specified path" >&2; \
	    exit 1; \
	fi; \
	\
	PLAYBOOK_CMD="$$ANSIBLE_PLAYBOOK playbook.yaml --tags '$$DOTS'"; \
	if [ -n "$$SKIP_DOTS" ]; then \
	    PLAYBOOK_CMD="$$PLAYBOOK_CMD --skip-tags '$$SKIP_DOTS'"; \
	fi; \
	\
	$$ANSIBLE_GALAXY collection install geerlingguy.mac; \
	\
	eval "$$PLAYBOOK_CMD"

formatter-check: ## Check formatting
	@prettier --check ./

formatter-fix: ## Fix formatting
	@prettier --write ./

spellchecker-check: ## Check spelling
	@typos ./
