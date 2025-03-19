# Terraform Lab

## Exercise 1: create a VM on VirtualBox using Terraform 

## Steps to Create the VM

### 1. Create a Directory for the Project

Open your terminal and create a new directory for the project.

```bash
mkdir es1
```

### 2. Create the main.tf file
Move into the directory and create the main.tf file:
```bash
cd es1
```
Create the main.tf file, in Lnux you can use:
```bash
nano main.tf
```
In the main.tf file for
- **Linux:** recommended to download the Vagrant box file (https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.1/providers/virtualbox.box) and enter the local path 
- **Windows**: provide the URL to the image

**Note:**
- In Unix systems, typically host_interface = “vboxnet0”
- In Windows, typically host_interface = “VirtualBox Host-Only Ethernet Adapter”
  
  To check the name of your Host-Only Network: open VirtualBox, click on “Tools” → “Network” and check the name of the Host-Only Network, you have created

Here's an example of the main.tf file:
```bash
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
  #image    = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.1/providers/virtualbox.box"
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
