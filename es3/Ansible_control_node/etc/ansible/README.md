# Terraform Lab

## Exercise 3b: Configure the 3-Legged Firewall topology using Ansible

### 1. Enter the Ansible Control Node 

Move to the directory /etc/ansible:
```bash
cd /etc/ansible
```

### 2. Configure ansible.cfg file

Edit the ansible.cfg file:
```bash
sudo nano ansible.cfg
```
```bash
# Since Ansible 2.12 (core):
# To generate an example config file (a "disabled" one with all default settings, commented out):
#               $ ansible-config init --disabled > ansible.cfg
#
# Also you can now have a more complete file by including existing plugins:
# ansible-config init --disabled -t all > ansible.cfg

# For previous versions of Ansible you can check for examples in the 'stable' branches of each version
# Note that this file was always incomplete  and lagging changes to configuration settings

# for example, for 2.9: https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
```

### 3. Configure hosts file
Edit the hosts file:
```bash
sudo nano hosts
```
Modify the hosts file, with the VM you want to control:
```bash
# This is the default ansible 'hosts' file.
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers:

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group:

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern, you can specify
# them like this:

## www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group:

## [dbservers]
##
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.com

[all]
vm-ext ansible_host=192.168.56.250 ansible_user=vagrant ansible_ssh_private_key_file=/home/samanta/.ssh/id_rsa ansible_sudo_pass=vagrant
vm-fw ansible_host=192.168.56.246 ansible_user=vagrant ansible_ssh_private_key_file=/home/samanta/.ssh/id_rsa ansible_sudo_pass=vagrant
vm-dmz ansible_host=192.168.56.247 ansible_user=vagrant ansible_ssh_private_key_file=/home/samanta/.ssh/id_rsa ansible_sudo_pass=vagrant
vm-int ansible_host=192.168.56.248 ansible_user=vagrant ansible_ssh_private_key_file=/home/samanta/.ssh/id_rsa ansible_sudo_pass=vagrant
```


### 3. Test the configuration
copy the ssh key with the command:
```bash
ssh-copy-id vagrant@<IP_VM-ext>
```

In case you receive the "permission denied (publickey)" error, run the following commands **from the terminal of the manage VM you have created using Terraform** to enable SSH connection using PasswordAuthentication:
1. Edit the sshd_config file:
```bash
sudo nano /etc/ssh/sshd_config
```
**Warning:** the keyboard is set to “us”, therefore:
- / corresponds to - on the “it” keyboard
- _ corresponds to ? on the “it” keyboard

2. Open the sshd_config file using a text editor, for this example nano. Press the key combination Ctrl + W and a search bar labeled "Search" will appear at the bottom of the page
Type PasswordAuthentication in the search bar and press “Enter”

3. The cursor will move to the first occurrence of “PasswordAuthentication” delete no and write yes

4. Press Ctrl + X to close the file. This will bring up a white bar at the bottom of the file asking whether to save the changes or not. Press y to save and then press Enter

5.	Restart the SSH service with the command:
```bash
sudo systemctl restart sshd
```

Then, from the terminal of the Ansible Control Node, enter again:
```bash
ssh-copy-id vagrant@<IP_VM-ext>
```

Repeat this operation for all the VMs and the test the configuration, running from the terminal of the Ansible Control Node:
```bash
ansible all -m ping
```

### 4. Create the role "enable_network_interfaces"
From the terminal of the Ansible Control Node, move to the directory roles:
```bash
cd /etc/ansible/roles
```
Then create the role using the command:
```bash
sudo ansible-galaxy init enable_network_interfaces
```
Move to the directory tasks and modify the file main.yml:
```bash
sudo nano tasks/main.yml
```
And enter:
```bash
---
- name: "Gather network interfaces facts"
  ansible.builtin.setup:
    filter: ansible_interfaces
  register: network_interfaces

- name: "Bring up all network interfaces"
  ansible.builtin.command:
    cmd: "ip link set {{ item }} up"
  loop: "{{ network_interfaces.ansible_facts.ansible_interfaces }}"
  when: item != 'lo'
  ignore_errors: yes
```
































