.PHONY: all
all: deps_install_all dots_install ## Install all dependencies and execute all Ansible tasks


.PHONY: deps_install_all
deps_install_all: deps_install_python deps_install_ansible ## Install all dependencies


python_version="3.12.2"
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
# Function to check command existence
cmd_exists = $(or $(shell which $1 2>/dev/null),$(shell [ -x $2 ] && echo $2))
# Select ansible-galaxy and ansible-playbook based on the ANSIBLE_PATH variable
ANSIBLE_PATH ?= auto
ifeq ($(ANSIBLE_PATH),global)
  ANSIBLE_GALAXY := $(shell which ansible-galaxy 2>/dev/null)
  ANSIBLE_PLAYBOOK := $(shell which ansible-playbook 2>/dev/null)
else ifeq ($(ANSIBLE_PATH),local)
  ANSIBLE_GALAXY := $(shell [ -x ./tmp/bin/ansible-galaxy ] && echo ./tmp/bin/ansible-galaxy)
  ANSIBLE_PLAYBOOK := $(shell [ -x ./tmp/bin/ansible-playbook ] && echo ./tmp/bin/ansible-playbook)
else
  ANSIBLE_GALAXY := $(call cmd_exists,ansible-galaxy,./tmp/bin/ansible-galaxy)
  ANSIBLE_PLAYBOOK := $(call cmd_exists,ansible-playbook,./tmp/bin/ansible-playbook)
endif
# Construct the ansible-playbook command with tags and skip-tags
PLAYBOOK_CMD := $(ANSIBLE_PLAYBOOK) playbook.yaml --tags "$(TAGS)"
ifneq ($(SKIP_TAGS),)
  PLAYBOOK_CMD += --skip-tags "$(SKIP_TAGS)"
endif
.PHONY: dots_install
dots_install: ## Install applications and setup dotfiles
ifndef ANSIBLE_GALAXY
	$(error "ansible-galaxy is not installed or not found in specified path")
endif
ifndef ANSIBLE_PLAYBOOK
	$(error "ansible-playbook is not installed or not found in specified path")
endif
	@$(ANSIBLE_GALAXY) collection install geerlingguy.mac
	@$(PLAYBOOK_CMD)


.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) |  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
