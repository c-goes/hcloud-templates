.PHONY: packer
packer:
	packer build -var-file=secret.pkrvars.hcl ubuntu-zfshome.pkr.hcl

.PHONY: terraform
terraform:
	terraform plan
	terraform apply

.PHONY: ansible
ansible:
	ansible-playbook -i hosts ansible-install-containers.yml
