terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "vm2" {
  count     = 1
  name      = "vm2"
  # image     = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "null_resource" "configure_networks" {
  depends_on = [virtualbox_vm.vm2]
  
  provisioner "local-exec" {
    command = <<-EOT
      # Spegni la VM se è accesa
      VBoxManage controlvm vm2 poweroff || true
      sleep 5
      # Aggiungi interfaccia di rete interna subnet_a
      VBoxManage modifyvm vm2 --nic2 intnet --intnet2 subnet_a
      # Aggiungi interfaccia NAT
      VBoxManage modifyvm vm2 --nic3 nat
      # Riavvia la VM
      VBoxManage startvm vm2 --type headless
    EOT
  }
}

output "vm2_IPAddr" {
  value = element(virtualbox_vm.vm2.*.network_adapter.0.ipv4_address, 0)
}
