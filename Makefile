python_version="3.12.0"
ansible_version="8.5.0"

.PHONY: all
all: deps_install_all  ## Install all dependencies and execute all Ansible tasks


.PHONY: deps_install_all
deps_install_all: deps_install_python deps_install_ansible  ## Install all dependencies


.PHONY: deps_install_python
deps_install_python:  ## Install python to ./tmp directory
	@git clone https://github.com/pyenv/pyenv.git ./tmp/pyenv; \
	./tmp/pyenv/plugins/python-build/bin/python-build $(python_version) ./tmp;


.PHONY: deps_install_ansible
deps_install_ansible:  ## Install ansible using python in ./tmp directory
	@./tmp/bin/python -m pip install ansible==${ansible_version}


.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) |  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
