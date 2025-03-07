# Configurazione Terraform per una architettura 3-legged firewall
terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

# Definizione delle VM

# vm-ext (External Network)
resource "virtualbox_vm" "vm-ext" {
  name      = "vm-ext"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

# vm-int (Internal Network)
resource "virtualbox_vm" "vm-int" {
  name      = "vm-int"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

# vm-dmz (DMZ Network)
resource "virtualbox_vm" "vm-dmz" {
  name      = "vm-dmz"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

# vm-fw (Firewall 3-legged e DHCP server)
resource "virtualbox_vm" "vm-fw" {
  name      = "vm-fw"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 2
  memory    = "1024 mib"  # Più risorse per il firewall
  user_data = file("${path.module}/user_data")
  
  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

# Configurazione delle reti aggiuntive
resource "null_resource" "configure_networks" {
  depends_on = [
    virtualbox_vm.vm-ext,
    virtualbox_vm.vm-int,
    virtualbox_vm.vm-dmz,
    virtualbox_vm.vm-fw
  ]
  
  # vm-ext: subnet_a, NAT
  provisioner "local-exec" {
    command = <<-EOT
      # Spegni la VM se è accesa
      VBoxManage controlvm vm-ext poweroff || true
      sleep 5
      # Aggiungi interfaccia subnet_a
      VBoxManage modifyvm vm-ext --nic2 intnet --intnet2 subnet_a
      # Aggiungi interfaccia NAT
      VBoxManage modifyvm vm-ext --nic3 nat
      # Riavvia la VM
      VBoxManage startvm vm-ext --type headless
    EOT
  }
  
  # vm-int: subnet_b
  provisioner "local-exec" {
    command = <<-EOT
      # Spegni la VM se è accesa
      VBoxManage controlvm vm-int poweroff || true
      sleep 5
      # Aggiungi interfaccia subnet_b
      VBoxManage modifyvm vm-int --nic2 intnet --intnet2 subnet_b
      # Riavvia la VM
      VBoxManage startvm vm-int --type headless
    EOT
  }
  
  # vm-dmz: subnet_dmz, NAT
  provisioner "local-exec" {
    command = <<-EOT
      # Spegni la VM se è accesa
      VBoxManage controlvm vm-dmz poweroff || true
      sleep 5
      # Aggiungi interfaccia subnet_dmz
      VBoxManage modifyvm vm-dmz --nic2 intnet --intnet2 subnet_dmz
      # Aggiungi interfaccia NAT
      VBoxManage modifyvm vm-dmz --nic3 nat
      # Riavvia la VM
      VBoxManage startvm vm-dmz --type headless
    EOT
  }
  
  # vm-fw (3-legged firewall): subnet_a, subnet_b, subnet_dmz, NAT
  provisioner "local-exec" {
    command = <<-EOT
      # Spegni la VM se è accesa
      VBoxManage controlvm vm-fw poweroff || true
      sleep 5
      # Aggiungi interfaccia subnet_a
      VBoxManage modifyvm vm-fw --nic2 intnet --intnet2 subnet_a
      # Aggiungi interfaccia subnet_b
      VBoxManage modifyvm vm-fw --nic3 intnet --intnet3 subnet_b
      # Aggiungi interfaccia subnet_dmz
      VBoxManage modifyvm vm-fw --nic4 intnet --intnet4 subnet_dmz
      # Aggiungi interfaccia NAT
      VBoxManage modifyvm vm-fw --nic5 nat
      # Riavvia la VM
      VBoxManage startvm vm-fw --type headless
    EOT
  }
}

# Output delle informazioni sugli IP scheda di rete host-only
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

