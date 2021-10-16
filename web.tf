# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
# variable "hcloud_token" {
#     sensitive = true # Requires terraform >= 0.14
# }



terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.30.0"
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


data "hcloud_image" "ubuntu_zfshome" {
  with_selector = "type=ubuntu-zfshome"
}

# Create a server
resource "hcloud_server" "web" {
    name = "my-server"
    image = data.hcloud_image.ubuntu_zfshome.id
    server_type = "cx21"
    ssh_keys = [ hcloud_ssh_key.mykey.id ]
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