# Terraform Lab

## Exercise 2c: create a VM with multiple network interfaces using Terraform

## Steps to Create the VM

### 1. Create a Directory for the Project

Open your PowerShell terminal and create a new directory for the project.

```bash
mkdir es2-c
```

### 2. Create the main.tf file
Move into the directory and create the main.tf file:
```bash
cd es2-c
```
With this configuration file we will be able to create a VM, named "vm2" with:
- RAM: 512 MB
- 1 CPU
- Image: vagrant box ubuntu 18.04

“vm2” will have three different network interfaces, each with a specific purpose:
- **Host-Only Network Adapter (nic1):** allows communication between the host and the VM but does not permit traffic to the internet or other networks
- **Internal Network Adapter (nic2):** creates a private isolated network called "subnet_a" that can be used to connect multiple VMs together, but without access to the outside
- **NAT (nic3):** allows the VM to access the internet using the host's IP address as a gateway

Create the main.tf file, that should be as follows (for Windows, provide the URL to the image):
```bash
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
```
Once you've added the content, press CTRL + X to exit, then press Y to save the file

### 3. Create the user_data File

Next, create the user_data file, which can remain empty for this exercise:

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
