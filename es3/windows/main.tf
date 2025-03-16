terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "vm-ext" {
  name   = "vm-ext"
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.1/providers/virtualbox.box"
  cpus   = 1
  memory = "512 mib"
  user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}

resource "virtualbox_vm" "vm-int" {
  name   = "vm-int"
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.1/providers/virtualbox.box"
  cpus   = 1
  memory = "512 mib"
  user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}

resource "virtualbox_vm" "vm-dmz" {
  name   = "vm-dmz"
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.1/providers/virtualbox.box"
  cpus   = 1
  memory = "512 mib"
  user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}

resource "virtualbox_vm" "vm-fw" {
  name   = "vm-fw"
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.1/providers/virtualbox.box"
  cpus   = 2
  memory = "1024 mib"
  user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
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
      Start-Process -NoNewWindow -FilePath "powershell" -ArgumentList @"
      Write-Host 'Spegnimento vm-ext...'
      VBoxManage controlvm vm-ext poweroff

      do {
          Start-Sleep -Seconds 5
          $status = VBoxManage showvminfo vm-ext --machinereadable | Select-String -Pattern 'VMState=\"poweroff\"'
          Write-Host 'Attendo lo spegnimento di vm-ext...'
      } while ($status -eq $null)

      Write-Host 'vm-ext spenta. Configuro la rete...'
      VBoxManage modifyvm vm-ext --nic3 intnet --intnet3 subnet_a
      VBoxManage modifyvm vm-ext --nic2 nat
      VBoxManage startvm vm-ext --type headless
      Write-Host 'vm-ext riavviata!'
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  provisioner "local-exec" {
    command = <<-EOT
      Start-Process -NoNewWindow -FilePath "powershell" -ArgumentList @"
      Write-Host 'Spegnimento vm-int...'
      VBoxManage controlvm vm-int poweroff

      do {
          Start-Sleep -Seconds 5
          $status = VBoxManage showvminfo vm-int --machinereadable | Select-String -Pattern 'VMState=\"poweroff\"'
          Write-Host 'Attendo lo spegnimento di vm-int...'
      } while ($status -eq $null)

      Write-Host 'vm-int spenta. Configuro la rete...'
      VBoxManage modifyvm vm-int --nic4 intnet --intnet4 subnet_b
      VBoxManage startvm vm-int --type headless
      Write-Host 'vm-int riavviata!'
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

  provisioner "local-exec" {
    command = <<-EOT
      Start-Process -NoNewWindow -FilePath "powershell" -ArgumentList @"
      Write-Host 'Spegnimento vm-dmz...'
      VBoxManage controlvm vm-dmz poweroff

      do {
          Start-Sleep -Seconds 5
          $status = VBoxManage showvminfo vm-dmz --machinereadable | Select-String -Pattern 'VMState=\"poweroff\"'
          Write-Host 'Attendo lo spegnimento di vm-dmz...'
      } while ($status -eq $null)

      Write-Host 'vm-dmz spenta. Configuro la rete...'
      VBoxManage modifyvm vm-dmz --nic5 intnet --intnet5 subnet_dmz
      VBoxManage modifyvm vm-dmz --nic2 nat
      VBoxManage startvm vm-dmz --type headless
      Write-Host 'vm-dmz riavviata!'
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }

 provisioner "local-exec" {
    command = <<-EOT
      Start-Process -NoNewWindow -FilePath "powershell" -ArgumentList @"
      Write-Host 'Spegnimento vm-fw...'
      VBoxManage controlvm vm-fw poweroff

      do {
          Start-Sleep -Seconds 5
          $status = VBoxManage showvminfo vm-fw --machinereadable | Select-String -Pattern 'VMState=\"poweroff\"'
          Write-Host 'Attendo lo spegnimento di vm-fw...'
      } while ($status -eq $null)

      Write-Host 'vm-fw spenta. Configuro la rete...'
      VBoxManage modifyvm vm-fw --nic3 intnet --intnet3 subnet_a
      VBoxManage modifyvm vm-fw --nic4 intnet --intnet4 subnet_b
      VBoxManage modifyvm vm-fw --nic5 intnet --intnet5 subnet_dmz
      VBoxManage modifyvm vm-fw --nic2 nat
      VBoxManage startvm vm-fw --type headless
      Write-Host 'vm-fw riavviata!'
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}


output "vm-ext_hostonly_ip" {
  value       = virtualbox_vm.vm-ext.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-ext"
}

output "vm-int_hostonly_ip" {
  value       = virtualbox_vm.vm-int.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-int"
}

output "vm-dmz_hostonly_ip" {
  value       = virtualbox_vm.vm-dmz.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-dmz"
}

output "vm-fw_hostonly_ip" {
  value       = virtualbox_vm.vm-fw.network_adapter.0.ipv4_address
  description = "Indirizzo IP dell'interfaccia host-only di vm-fw"
}
