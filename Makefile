.PHONY: init init_network init_webserver \
clean clean_network clean_webserver \
apply \
destroy destroy_webserver destroy_network

.DEFAULT_GOAL := apply

init: init_webserver
clean: clean_network clean_webserver
apply: apply_webserver
destroy: destroy_network

TFVARS = $$HOME/terraform_secrets/aws-terraform-tuto02.tfvars
BUCKET = $(shell awk '/bucket/{print $$NF}' ${TFVARS})
REGION = $(shell awk '/region/{print $$NF}' ${TFVARS})
NETWORK_KEY = $(shell awk '/_network_key/{print $$NF}' ${TFVARS})
WEBSERVER_KEY = $(shell awk '/_webserver_key/{print $$NF}' ${TFVARS})

init_network:
	cd 01-network; \
	terraform init \
	-backend-config="bucket=${BUCKET}" \
	-backend-config="key=${NETWORK_KEY}" \
	-backend-config="region=${REGION}"

init_webserver: init_network
	cd 02-webserver; \
	terraform init \
	-backend-config="bucket=${BUCKET}" \
	-backend-config="key=${WEBSERVER_KEY}" \
	-backend-config="region=${REGION}"

clean_network:
	rm -rf 01-network/.terraform
	rm -f apply_network

clean_webserver:
	rm -rf 02-webserver/.terraform
	rm -f apply_webserver

apply_network:
	cd 01-network; \
	terraform apply -auto-approve -var-file="${TFVARS}"
	@touch $@

apply_webserver: apply_network
	cd 02-webserver; \
	terraform apply -auto-approve -var-file="${TFVARS}"
	@touch $@

destroy_webserver:
ifeq ($(shell [ -f apply_webserver ] && echo exists), exists)
	cd 02-webserver; \
	terraform destroy -auto-approve -var-file="${TFVARS}"
	@rm -f apply_webserver
endif

destroy_network: destroy_webserver
ifeq ($(shell [ -f apply_network ] && echo exists), exists)
	cd 01-network; \
	terraform destroy -auto-approve -var-file="${TFVARS}"
	@rm -f apply_network
endif
