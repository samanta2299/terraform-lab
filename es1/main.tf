#20230607.0.1
#https://portal.cloud.hashicorp.com/vagrant/discover/ubuntu/bionic64/versions/20230607.0.1
terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "vm1" {
  count     = 1
  name      = "vm1"
#  image     = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

output "vm1_IPAddr" {
  value = element(virtualbox_vm.vm1.*.network_adapter.0.ipv4_address, 0)
}
