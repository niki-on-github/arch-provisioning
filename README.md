# Archlinux provisioning with Ansible

This repo contains the Ansible playbooks and configuration used to manage and automate my arch based pc setup. Feel free to look around. Be aware that I have configured my environment to fit my workflow. Still **WIP**

## Setup

### Install Ansible dependencies

```bash
ansible-galaxy install -r requirements.yml
```

## Provisioning

```bash
ansible-playbook -i ./inventory/localhost ./playbooks/base.yml -K
```
