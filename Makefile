.DEFAULT_GOAL    := help
AWK              := /usr/bin/awk
TERRAFORM        = $(HOME)/opt/bin/terraform
TMP              := $(CURDIR)/.tmp
VPATH            := $(TMP)
TFVARS           ?= aws-terraform-tuto02.tfvars

# If default TERRAFORM does not exist then looks for in PATH variable
ifeq "$(wildcard $(TERRAFORM))" ""
  TERRAFORM_FOUND := $(shell which terraform)
  TERRAFORM = $(if $(TERRAFORM_FOUND),$(TERRAFORM_FOUND),$(error terraform is not found))
endif

ifeq "$(wildcard $(TFVARS))" ""
  $(error $(TFVARS) is not found)
endif

# $(call init,service)
define init
  . $(TFVARS) && \
  cd $1 && \
  $(TERRAFORM) init \
  -backend-config="bucket=$$TF_VAR_bucket" \
  -backend-config="key=$$TF_VAR_$1_key" \
  -backend-config="region=$$TF_VAR_region"
endef

# $(call apply,service)
define apply
  . $(TFVARS) && \
  cd $1 && \
  $(TERRAFORM) apply -auto-approve
  @touch $(TMP)/apply_$1
endef

# $(call destroy,service)
define destroy
  . $(TFVARS) && \
  cd $1 && \
  $(TERRAFORM) destroy -auto-approve
  @rm -f $(TMP)/apply_$1
endef

# $(call clean,service)
define clean
  rm -rf $1/.terraform
  rm -f $(TMP)/apply_$1
endef

.PHONY: help
help: ## Show help
	@echo "Usage: make TARGET\n"
	@echo "Targets:"
	@$(AWK) -F ":.* ##" '/.*:.*##/{ printf "%-18s%s\n", $$1, $$2 }' \
	$(MAKEFILE_LIST) \
	| grep -v AWK

.PHONY: init_network
init_network: ## Initialize Terraform working directory for network
	$(call init,network)

.PHONY: init_webserver
init_webserver: init_network ## Initialize Terraform working directory for webserver
	$(call init,webserver)

.PHONY: init
init: init_webserver ## Initialize all Terraform working directories

apply_network: ## Build network
ifeq "$(wildcard $(TMP))" ""
	@mkdir $(TMP)
endif
	$(call apply,network)

apply_webserver: apply_network ## Build webserver
	$(call apply,webserver)

.PHONY: all
all: apply_webserver ## Build all

.PHONY: destroy_webserver
destroy_webserver: ## Destroy webserver
ifneq "$(wildcard $(TMP)/apply_webserver)" ""
	$(call destroy,webserver)
endif

.PHONY: destroy_network
destroy_network: destroy_webserver ## Destroy network
ifneq "$(wildcard $(TMP)/apply_network)" ""
	$(call destroy,network)
	@rmdir $(TMP)
endif

.PHONY: destroy
destroy: destroy_network ## Destroy all

.PHONY: clean_network
clean_network: ## Remove Terraform working directory of network
	$(call clean,network)

.PHONY: clean_webserver
clean_webserver: ## Remove Terraform working directory of webserver
	$(call clean,webserver)

.PHONY: clean
clean: clean_network clean_webserver ## Remove all Terraform working directories
ifneq "$(wildcard $(TMP))" ""
	@rmdir $(TMP)
endif
