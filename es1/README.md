# Terraform Lab

## Exercise 1: create a VM on VirtualBox using Terraform 

Open the terminal and create a directory, for example, es1
'''
bash
mkdir es1
'''

Move into the directory and create main.tf
'''
bash
cd es1
nano main.tf
'''
In the main.tf file, for Linux is recommended to download the vagrant box file and enter the local path and for Windows to provide the URL to the image
'''
bash
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
  #image     = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20180903.0.0/providers/virtualbox.box"
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
'''

Then CTRL + X to close nano and y to save the file

Then create the file user_data, which will be empty
'''
bash
nano user_data
'''
Then CTRL + X to close nano and y to save the file

The configuration is ready. From the terminal, in the directory es1, where the main.tf and user_data are saved, run:
'''
bash
terraform init
'''
'''
bash
terraform apply --auto-approve
'''
And your vm will be automatically created
