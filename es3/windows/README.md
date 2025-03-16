# Terraform Lab

## Exercise 3a: Create a complex network topology (3-Legged Firewall) using Terraform to create VMs on VirtualBox 

## Steps to Create the VM

### 1. Create a Directory for the Project

Open your PowerShell terminal and create a new directory for the project.

```bash
mkdir es3
```

### 2. Create the main.tf file
Move into the directory and create the main.tf file:
```bash
cd es3
```
We will be using Terraform to create a basic configuration of the 3-Legged Firewall network topology. Terraform will creare 4 VMs:
- **vm-ext:** VM in the external network, with the following network interfaces:
  - **NAT:**  for internet access
  - **Host-Only:** for communication with the Ansible Control Node
  - **subnet_a:** a subnet that contains the VMs located in the external network for network segmentation purposes
  
- **vm-fw:** DHCP server and 3-Legged Firewall, with the following network interfaces:
  - **NAT:**  for internet access
  - **Host-Only:** for communication with the Ansible Control Node
  - **subnet_a, subnet_b, subnet_dmz:** to communicate with all network segments

- **vm-dmz:** VM in the DMZ network, with the following network interfaces:
  - **NAT:**  for internet access
  - **Host-Only:** for communication with the Ansible Control Node
  - **subnet_dmz:** is a subnet that contains the VMs located in the DMZ network for network segmentation purposes
- **vm-int:** VM in the internal network, with the following network interfaces:
  - **Host-Only:** for communication with the Ansible Control Node
  - **subnet_b:** a subnet that contains the VMs located in the internal network for network segmentation purposes

Create the terraform main.tf file and enter the following configuration:

```bash
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
```
Once you've added the content, press CTRL + X to exit, then press Y to save the file

### 3. Create the user_data File

Next, **create the user_data file**, which can remain empty for this exercise

### 4. Initialize Terraform

In the terminal, within the es1 directory (where both main.tf and user_data are saved), run the following command to initialize Terraform:
```bash
terraform init
```
### 5. Apply the Terraform Configuration

Run the following command to apply the configuration and create the VM:
```bash
terraform apply --auto-approve
```
Terraform will automatically create the VM based on the configuration

### 6. Access the VM
Once the process is complete, Terraform will output the IP address of the VM. Your VM will now be accessible at the provided IP address

### Clean Up

When you are finished with the VM, you can destroy it by running:
```bash
terraform destroy --auto-approve
```
This will delete the VM created by Terraform and clean up your environment
