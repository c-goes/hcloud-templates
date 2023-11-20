packer {
  required_plugins {
    hcloud = {
      source  = "github.com/hetznercloud/hcloud"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "hcloud_token" {
    sensitive = true # Requires terraform >= 0.14
}

source "hcloud" "jammy_home" {
  image        = "ubuntu-22.04"
  location     = "nbg1"
  server_type  = "cx11"
  upgrade_server_type = "cx51"
  ssh_keys     = ["mykey"]
  ssh_username = "root"
  token        = "${var.hcloud_token}"
  rescue       = "linux64"
  snapshot_name = "universal-server-template-jammy-home"
  snapshot_labels = {
    "type" = "universal-server-template-jammy-home"
  }
}

source "hcloud" "bookworm_home" {
  image        = "debian-12"
  location     = "nbg1"
  server_type  = "cx11"
  upgrade_server_type = "cx51"
  temporary_key_pair_type = "ed25519"
  ssh_keys     = ["mykey"]
  ssh_username = "root"
  token        = "${var.hcloud_token}"
  rescue       = "linux64"
  snapshot_name = "universal-server-template-bookworm-home"
  snapshot_labels = {
    "type" = "universal-server-template-bookworm-home"
  }
}


build {
  sources = ["source.hcloud.bookworm_home", "source.hcloud.jammy_home"]

  provisioner "shell" {
    inline = [
      "echo provisioning all the things",
    ]
  }

  provisioner "ansible" {
      #extra_arguments = [ "-vvvv" ]
      playbook_file = "./ansible-packer.yml"
      user = "root"
      use_proxy = false
  }

}
