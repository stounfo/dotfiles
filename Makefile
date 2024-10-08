.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) |  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'


.PHONY: all
all: deps_install_all dots_install ## Install all dependencies and execute all Ansible tasks


.PHONY: deps_install_all
deps_install_all: deps_install_python deps_install_ansible ## Install all dependencies


python_version="3.13.0"
.PHONY: deps_install_python
deps_install_python: ## Install python to ./tmp directory
	@git clone https://github.com/pyenv/pyenv.git ./tmp/pyenv; \
	./tmp/pyenv/plugins/python-build/bin/python-build $(python_version) ./tmp;


ansible_version="8.5.0"
.PHONY: deps_install_ansible
deps_install_ansible: ## Install ansible using python in ./tmp directory
	@./tmp/bin/python -m pip install ansible==${ansible_version}


TAGS ?= all
SKIP_TAGS ?=
# Select ansible-galaxy and ansible-playbook based on the ANSIBLE_PATH variable
ANSIBLE_PATH ?= auto
PHONY: dots_install
dots_install:
	@TAGS="${TAGS}"; \
	export PATH="/opt/homebrew/bin:$$PATH" \
	SKIP_TAGS="${SKIP_TAGS}"; \
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
	PLAYBOOK_CMD="$$ANSIBLE_PLAYBOOK playbook.yaml --tags '$$TAGS'"; \
	if [ -n "$$SKIP_TAGS" ]; then \
	    PLAYBOOK_CMD="$$PLAYBOOK_CMD --skip-tags '$$SKIP_TAGS'"; \
	fi; \
	\
	$$ANSIBLE_GALAXY collection install geerlingguy.mac; \
	\
	eval "$$PLAYBOOK_CMD"
