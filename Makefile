

.PHONY: container
container:
	podman build -v $(shell pwd):/tpl -t localhost/packer-ansible packer-ansible-container
	podman build -v $(shell pwd):/tpl -t localhost/terraform-ansible terraform-ansible-container
	podman build -v $(shell pwd):/tpl -t localhost/hcloud-container hcloud-container

.PHONY: packershell
packershell:
	podman run -i -t -w /tpl -v $(shell pwd):/tpl -v ~/.ssh/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro --entrypoint="/bin/sh" localhost/packer-ansible

.PHONY: packer
packer:
	podman run -i -t -w /tpl -v $(shell pwd):/tpl -v ~/.ssh/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro localhost/packer-ansible build -var-file=secret.pkrvars.hcl universal-server-template.pkr.hcl

.PHONY: deletesnapshots
deletesnapshots:
	podman run -i -w /tpl --env-file=secret.env --entrypoint=/usr/local/bin/delete.sh localhost/hcloud-container universal-server-template-bookworm-home
	podman run -i -w /tpl --env-file=secret.env --entrypoint=/usr/local/bin/delete.sh localhost/hcloud-container universal-server-template-jammy-home

.PHONY: terraformshell
terraformshell:
	podman run -i -t -w /tpl -v $(shell pwd):/tpl -v ~/.ssh/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro --entrypoint="/bin/sh" localhost/terraform-ansible

.PHONY: terraform
terraform:
	podman run -i -t -w /tpl -v $(shell pwd):/tpl -v ~/.ssh/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro localhost/terraform-ansible plan
	podman run -i -t -w /tpl -v $(shell pwd):/tpl -v ~/.ssh/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro localhost/terraform-ansible apply

.PHONY: ansibleinventory
ansibleinventory:
	podman run -i -t -w /tpl -v $(shell pwd):/tpl -v ~/.ssh/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro --entrypoint="ansible-inventory" localhost/terraform-ansible -i inventory.yml --graph --vars


.PHONY: ansible
ansible:
	podman run -i -t -w /tpl -v $(shell pwd):/tpl -v ~/.ssh/known_hosts:/root/.ssh/known_hosts:ro -v ~/.ssh/id_ed25519:/root/.ssh/id_ed25519:ro -v ~/.ssh/id_ed25519.pub:/root/.ssh/id_ed25519.pub:ro --entrypoint="ansible-playbook" localhost/terraform-ansible -i inventory.yml ansible-server.yml
