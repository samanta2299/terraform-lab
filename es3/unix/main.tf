terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "vm-ext" {
  name      = "vm-ext"
  #Replace with local image or with https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "vm-int" {
  name      = "vm-int"
  #Replace with local image or with https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "vm-dmz" {
  name      = "vm-dmz"
  #Replace with local image or with https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "vm-fw" {
  name      = "vm-fw"
  #Replace with local image or with https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 2
  memory    = "1024 mib"
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "null_resource" "configure_networks" {
  depends_on = [
    virtualbox_vm.vm-ext,
    virtualbox_vm.vm-int,
    virtualbox_vm.vm-dmz,
    virtualbox_vm.vm-fw
  ]
  
  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm vm-ext poweroff || true
      sleep 5
      VBoxManage modifyvm vm-ext --nic2 nat
      VBoxManage modifyvm vm-ext --nic3 intnet --intnet3 subnet_a
      VBoxManage startvm vm-ext --type headless
    EOT
  }
  
provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm vm-int poweroff || true
      sleep 5
      VBoxManage modifyvm vm-int --nic4 intnet --intnet4 subnet_b
      VBoxManage startvm vm-int --type headless
    EOT
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm vm-dmz poweroff || true
      sleep 5
      VBoxManage modifyvm vm-dmz --nic2 nat
      VBoxManage modifyvm vm-dmz --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm vm-dmz --type headless
    EOT
  }
  
  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm vm-fw poweroff || true
      sleep 5
      VBoxManage modifyvm vm-fw --nic2 nat
      VBoxManage modifyvm vm-fw --nic3 intnet --intnet3 subnet_a
      VBoxManage modifyvm vm-fw --nic4 intnet --intnet4 subnet_b
      VBoxManage modifyvm vm-fw --nic5 intnet --intnet5 subnet_dmz
      VBoxManage modifyvm vm-fw --nic2 nat
      VBoxManage startvm vm-fw --type headless
    EOT
  }
}

output "vm-ext_hostonly_ip" {
  value = virtualbox_vm.vm-ext.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-ext"
}

output "vm-int_hostonly_ip" {
  value = virtualbox_vm.vm-int.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-int"
}

output "vm-dmz_hostonly_ip" {
  value = virtualbox_vm.vm-dmz.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-dmz"
}

output "vm-fw_hostonly_ip" {
  value = virtualbox_vm.vm-fw.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-fw"
}
