terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "vm2" {
  count  = 1
  name   = "vm2"
  image  = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.1/providers/virtualbox.box"
  cpus   = 1
  memory = "512 mib"
  user_data = file("${path.module}/user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "VirtualBox Host-Only Ethernet Adapter"
  }
}

resource "null_resource" "configure_networks" {
  depends_on = [virtualbox_vm.vm2]

  provisioner "local-exec" {
    command = <<-EOT
      Start-Process -NoNewWindow -FilePath "powershell" -ArgumentList @"
      VBoxManage controlvm vm2 poweroff
      Start-Sleep -Seconds 5
      VBoxManage modifyvm vm2 --nic2 intnet
      VBoxManage modifyvm vm2 --intnet2 subnet_a
      VBoxManage modifyvm vm2 --nic3 nat
      VBoxManage startvm vm2 --type headless
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}

output "vm2_IPAddr" {
  value = element(virtualbox_vm.vm2.*.network_adapter.0.ipv4_address, 0)
}
