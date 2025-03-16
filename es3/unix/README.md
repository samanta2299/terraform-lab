# Terraform Lab

## Exercise 3a: Create a complex network topology (3-Legged Firewall) using Terraform to create VMs on VirtualBox 

## Steps to Create the VM

### 1. Create a Directory for the Project

Open your terminal and create a new directory for the project.

```bash
mkdir es3
```

### 2. Create the main.tf file
Move into the directory and create the main.tf file:
```bash
cd es3
```
We will be using Terraform to create a basic configuration of the 3-Legged Firewall network topology. Terraform will creare 4 VMs:
- vm-ext: VM in the external network, with the following network interfaces:
  -- NAT:  for internet access
Host-Only: for communication with the Ansible Control Node
subnet_a: a subnet that contains the VMs located in the external network for network segmentation purposes
vm-fw: DHCP server and 3-Legged Firewall, with the following network interfaces:
NAT:  for internet access
Host-Only: for communication with the Ansible Control Node
subnet_a, subnet_b, subnet_dmz: to communicate with all network segments


```bash
nano main.tf
```
In the main.tf file, for Linux, it is recommended to download the Vagrant box file and enter the local path
For Windows, provide the URL to the image
Here's an example of the main.tf file:
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
  count     = 1
  name      = "vm2"
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
```
Once you've added the content, press CTRL + X to exit, then press Y to save the file

### 3. Create the user_data File

Next, create the user_data file, which can remain empty for this exercise:
```bash
nano user_data
```
Afterwards, press CTRL + X to exit, then press Y to save the empty file

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
