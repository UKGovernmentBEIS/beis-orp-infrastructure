
ifndef VERBOSE
.SILENT:
endif

help:
	echo "Help here:"
	echo "  This makefile gives the user the ability to safely deploy this project to your prefered environment. "
	echo ""
	echo "Examples:"
	echo ""
	echo "To deploy the Application to Development"
	echo "        make  development terraform-plan"
	echo ""


.PHONY: development
development:
	$(eval include global_config/development.sh)


.PHONY: test
test:
	$(eval include global_config/test.sh)

.PHONY: preprod
preprod:
	$(eval include global_config/preprod.sh)


.PHONY: production
production:
	$(eval include global_config/prod.sh)


terraform-init:
	terraform  init -upgrade -reconfigure -backend-config=global_config/${ENVIRONMENT}.conf


terraform-plan: terraform-init
	terraform  plan -var-file "${CONFIG}.tfvars"


terraform-apply: terraform-init
	terraform apply -var-file "${CONFIG}.tfvars" ${AUTO_APPROVE}


terraform-destroy: terraform-init
	terraform  destroy -var-file "${CONFIG}.tfvars" ${AUTO_APPROVE}
