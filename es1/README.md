# Esercizio Terraform per creare una macchina virtuale con VirtualBox

## Descrizione

Questo progetto utilizza Terraform per creare e configurare una macchina virtuale su VirtualBox. La macchina virtuale viene configurata con una memoria di 512 MB, 1 CPU e una rete host-only. È anche configurata per utilizzare un'immagine di Ubuntu, che viene caricata durante il processo di creazione.

In questo README, spiegherò tutti i passaggi necessari per eseguire il progetto, i file coinvolti e come usarli.

## Prerequisiti

- **Terraform**: versione minima 0.12
- **VirtualBox**: assicurati di avere **VirtualBox** installato

## Istruzioni per l'uso

1. **Installazione di Terraform**:
   Assicurati che Terraform sia installato. Se non lo è, puoi seguirne la guida di installazione ufficiale: https://www.terraform.io/downloads.html

2. **Clona il repository**:
   ```bash
   git clone https://github.com/TUO_USERNAME/terraform-vm-project.git
   cd terraform-vm-project

File del Progetto
main.tf: File di configurazione di Terraform

Il file main.tf è il cuore del progetto. Contiene tutte le configurazioni di Terraform per creare e gestire la macchina virtuale su VirtualBox.

Contenuto di main.tf:

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
  # Utilizza un'immagine di Ubuntu, puoi anche utilizzare un URL per scaricarla
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
