.DEFAULT_GOAL := help
AWK           := awk
TERRAFORM     = $(HOME)/opt/bin/terraform
TMP           := $(CURDIR)/.tmp
VPATH         := $(TMP)
TFVARS        ?= aws-terraform-tuto02.tfvars

# If the default TERRAFORM does not exist then looks for in the PATH variable
ifeq "$(wildcard $(TERRAFORM))" ""
  TERRAFORM_FOUND := $(shell which terraform)
  TERRAFORM = $(if $(TERRAFORM_FOUND),$(TERRAFORM_FOUND),$(error terraform is not found))
endif

ifeq "$(wildcard $(TFVARS))" ""
  $(error $(TFVARS) is not found)
endif

# $(call init,service)
define init
  @if [ ! -d $1/.terraform ]; then \
    . $(TFVARS) && \
    cd $1 && \
    $(TERRAFORM) init \
    -backend-config="bucket=$$TF_VAR_bucket" \
    -backend-config="key=$$TF_VAR_$1_key" \
    -backend-config="region=$$TF_VAR_region"; \
  fi
endef

# $(call apply,service)
define apply
  @[ -d $(TMP) ] || mkdir $(TMP)

  . $(TFVARS) && \
  cd $1 && \
  $(TERRAFORM) apply -auto-approve
  @touch $(TMP)/apply_$1
endef

# $(call destroy,service)
define destroy
  @if [ -f $(TMP)/apply_$1 ]; then \
    . $(TFVARS) && \
    cd $1 && \
    $(TERRAFORM) destroy -auto-approve; \
    rm -f $(TMP)/apply_$1; \
  fi
endef

# $(call clean,service)
define clean
  rm -rf $1/.terraform
endef

# $(call clean_tmp)
define clean_tmp
  @if [ -d $(TMP) ]; then \
    rmdir $(TMP); \
  fi
endef

.PHONY: help
help: ## Show help
	@echo "Usage: make TARGET\n"
	@echo "Targets:"
	@$(AWK) -F ":.* ##" '/^[^#].*:.*##/{printf "%-18s%s\n", $$1, $$2}' \
	$(MAKEFILE_LIST) \
	| grep -v AWK

.PHONY: all
all: apply_webserver ## Build all

apply_webserver: apply_network ## Build webserver
	$(call init,$(word 2, $(subst _, ,$@)))
	$(call $(word 1, $(subst _, ,$@)),$(word 2, $(subst _, ,$@)))

apply_network: ## Build network
	$(call init,$(word 2, $(subst _, ,$@)))
	$(call $(word 1, $(subst _, ,$@)),$(word 2, $(subst _, ,$@)))

.PHONY: destroy
destroy: destroy_network ## Destroy all
	$(call clean_tmp)

.PHONY: destroy_network
destroy_network: destroy_webserver ## Destroy network
	$(call $(word 1, $(subst _, ,$@)),$(word 2, $(subst _, ,$@)))

.PHONY: destroy_webserver
destroy_webserver: ## Destroy webserver
	$(call $(word 1, $(subst _, ,$@)),$(word 2, $(subst _, ,$@)))

.PHONY: clean
clean: clean_webserver clean_network ## Remove all Terraform working directories
	$(call clean_tmp)

.PHONY: clean_webserver
clean_webserver: ## Remove Terraform working directory of webserver
	$(call $(word 1, $(subst _, ,$@)),$(word 2, $(subst _, ,$@)))

.PHONY: clean_network
clean_network: ## Remove Terraform working directory of network
	$(call $(word 1, $(subst _, ,$@)),$(word 2, $(subst _, ,$@)))
