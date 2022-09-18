WORKSPACE := $(shell terraform workspace show)
BUCKET := $(shell cat backend.tf | grep bucket | awk '{print $$3}')

ifeq ($(WORKSPACE),default)
	REMOTE_TFVARS_PATH := "s3://$(BUCKET)/terraform.tfvars"
	LOCAL_TFVARS_PATH := "tfvars/terraform.tfvars"
else
	REMOTE_TFVARS_PATH := "s3://$(BUCKET)/env:/$(WORKSPACE)/terraform.tfvars"
	LOCAL_TFVARS_PATH := "tfvars/$(WORKSPACE)/terraform.tfvars"
endif

push_vars:
	aws s3 cp --sse="AES256" $(LOCAL_TFVARS_PATH) $(REMOTE_TFVARS_PATH)

pull_vars:
	aws s3 cp --sse="AES256" $(REMOTE_TFVARS_PATH) $(LOCAL_TFVARS_PATH)
