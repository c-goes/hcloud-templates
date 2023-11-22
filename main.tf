# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
# variable "hcloud_token" {
#     sensitive = true # Requires terraform >= 0.14
# }



terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.44.1"
    }
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
    }
  }
}


provider "hcloud" {
    token = var.hcloud_token
}

resource "hcloud_ssh_key" "mykey" {
  name       = "mykey"
  public_key = file("~/.ssh/id_ed25519.pub")
}


data "hcloud_image" "universal_server_template_jammy_home" {
  with_selector = "type=universal-server-template-jammy-home"
}

resource "ansible_host" "web" {
  name   = hcloud_server.web.ipv4_address
  groups = ["webservers"]
  variables = {
    ansible_user                 = "root",
    ansible_ssh_private_key_file = "~/.ssh/id_ed25519",
    ansible_python_interpreter   = "/usr/bin/python3"
  }
}

resource "hcloud_server" "web" {
    name = "my-server"
    image = data.hcloud_image.universal_server_template_jammy_home.id
    server_type = "cx11"
    ssh_keys = [ hcloud_ssh_key.mykey.id ]
    location = "nbg1" // nbg1, fsn1, hel1
    user_data = <<EOF
#cloud-config
packages:
  - zfsutils-linux
  - ufw
runcmd:
  - [ zpool, import, tank ]
  - [ zfs, mount, tank/home ]
  - [ ufw, allow, ssh ]
  - [ ufw, enable ]
EOF
}