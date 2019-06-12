.PHONY: init init_network init_webserver \
clean clean_network clean_webserver \
apply \
destroy destroy_webserver destroy_network

.DEFAULT_GOAL := apply

TFVARS = aws-terraform-tuto02.tfvars

init: init_webserver
clean: clean_network clean_webserver
apply: apply_webserver
destroy: destroy_network

init_network:
	. ${TFVARS}; \
	cd 01-network; \
	terraform init \
	-backend-config="bucket=$$TF_VAR_bucket" \
	-backend-config="key=$$TF_VAR_network_key" \
	-backend-config="region=$$TF_VAR_region"

init_webserver: init_network
	. ${TFVARS}; \
	cd 02-webserver; \
	terraform init \
	-backend-config="bucket=$$TF_VAR_bucket" \
	-backend-config="key=$$TF_VAR_webserver_key" \
	-backend-config="region=$$TF_VAR_region"

clean_network:
	rm -rf 01-network/.terraform
	rm -f apply_network

clean_webserver:
	rm -rf 02-webserver/.terraform
	rm -f apply_webserver

apply_network:
	cd 01-network; \
	terraform apply -auto-approve
	@touch $@

apply_webserver: apply_network
	. ${TFVARS}; \
	cd 02-webserver; \
	terraform apply -auto-approve
	@touch $@

destroy_webserver:
ifeq ($(shell [ -f apply_webserver ] && echo exists), exists)
	. ${TFVARS}; \
	cd 02-webserver; \
	terraform destroy -auto-approve
	@rm -f apply_webserver
endif

destroy_network: destroy_webserver
ifeq ($(shell [ -f apply_network ] && echo exists), exists)
	cd 01-network; \
	terraform destroy -auto-approve
	@rm -f apply_network
endif
