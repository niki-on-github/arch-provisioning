# Archlinux provisioning with Ansible

> [!IMPORTANT]  
> I switched to NixOS for all my devices. Therefore this repository is not longer used.

This repo contains the Ansible playbooks and configuration used to manage and automate my arch based pc setup. Feel free to look around. Be aware that I have configured my environment to fit my workflow.

## Setup

### Install ansible

```bash
sudo pacman -Sy ansible python-pip
```

### Install Ansible dependencies

```bash
ansible-galaxy install -r requirements.yml
```

## Provisioning

```bash
ansible-playbook -i ./inventory/localhost ./playbooks/setup_001.yml -K
```
