.PHONY: init init_network init_webserver \
clean clean_network clean_webserver \
apply \
destroy destroy_webserver destroy_network

.DEFAULT_GOAL    := apply
TMP              := $(CURDIR)/.tmp
VPATH            := $(TMP)
TFVARS           ?= aws-terraform-tuto02.tfvars
TERRAFORM_EXISTS := $(shell which terraform)

ifndef TERRAFORM_EXISTS
  $(error terraform is not found)
endif

init:    init_webserver
apply:   apply_webserver
destroy: destroy_network
clean:   clean_network clean_webserver
ifneq "$(wildcard $(TMP))" ""
	@rmdir $(TMP)
endif

init_network:
	. $(TFVARS) && \
	cd 01-network && \
	terraform init \
	-backend-config="bucket=$$TF_VAR_bucket" \
	-backend-config="key=$$TF_VAR_network_key" \
	-backend-config="region=$$TF_VAR_region"

init_webserver: init_network
	. $(TFVARS) && \
	cd 02-webserver && \
	terraform init \
	-backend-config="bucket=$$TF_VAR_bucket" \
	-backend-config="key=$$TF_VAR_webserver_key" \
	-backend-config="region=$$TF_VAR_region"

apply_network:
ifeq "$(wildcard $(TMP))" ""
	@mkdir $(TMP)
endif
	cd 01-network && \
	terraform apply -auto-approve
	@touch $(TMP)/$@

apply_webserver: apply_network
	. $(TFVARS) && \
	cd 02-webserver && \
	terraform apply -auto-approve
	@touch $(TMP)/$@

clean_network:
	rm -rf 01-network/.terraform
	rm -f $(TMP)/apply_network

clean_webserver:
	rm -rf 02-webserver/.terraform
	rm -f $(TMP)/apply_webserver

destroy_webserver:
ifneq "$(wildcard $(TMP)/apply_webserver)" ""
	. $(TFVARS) && \
	cd 02-webserver && \
	terraform destroy -auto-approve
	@rm -f $(TMP)/apply_webserver
endif

destroy_network: destroy_webserver
ifneq "$(wildcard $(TMP)/apply_network)" ""
	cd 01-network && \
	terraform destroy -auto-approve
	@rm -f $(TMP)/apply_network
	@rmdir $(TMP)
endif
