# Templates for hcloud

My templates for hcloud using Packer, Ansible and Terraform

This repo uses

- Packer for creating a snapshot in hcloud that can be used to create servers from
- Ansible as Packer provisioner for preparing the image in rescue system that can be reused for hcloud servers
- Terraform for creating a hcloud server from the snapshot (via label)
- Ansible connecting directly to the server to run playbook


# Templates

Only one template available for the time being.

## Template for hosting containers with ZFS

- cloud-init for installing ufw and zfsutils-linux, and importing the pool
- Will make small partition for `/` (10G)
- Will make a large partition for ZFS (maximum)
- One dataset is mounted at `/home` for using rootless containers in Podman
- LXD installed and configured (ansible-install-containers.yml)
- Install Podman with ZFS storage backend (ansible-install-containers.yml)


# Installation

- add file `secret.pkrvars.hcl` and `terraform.tfvars` with content `hcloud_token = "xyz"`
- add file `secret.env` with content `HCLOUD_TOKEN=xyz`