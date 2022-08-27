#!/bin/bash

LBLUE='\033[1;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    cat <<EOF
Description:

    '`basename $0`' is a script to remote provision arch linux

Dependecies:

    - ansible

Usage:

    `basename $0` [IP] [SSH_USER] [PLAYBOOK]
EOF
    exit $1
}

error() {
    echo -e "${RED}ERROR: $1${NC}\n"
    usage 1
}

IP="$1"
SSH_USER="$2"
PLAYBOOK="$3"
[ -z "$IP" ] && error "Invalid arguments"
[ "$IP" = "-h" ] && usage 0
[ "$IP" = "--help" ] && usage 0
[ "$IP" = "help" ] && usage 0
[ -z "$(echo "$IP" | awk '/^([0-9]{1,3}[.]){3}([0-9]{1,3})$/{print $1}')" ] && error "Invalid IP"
[ -z "$SSH_USER" ] && error "Invalid arguments"
[ -z "$PLAYBOOK" ] && error "Invalid arguments"
[ -f "$PLAYBOOK" ] || error "Playbook not found"

echo "Ping $IP..."
ping -c 1 -W 2 $IP >/dev/null || error "Device not found!"

echo "Remote IP: $IP"

ansible-galaxy install -r requirements.yml

tmp_dir=$(mktemp -d)
echo "Temp Directory: $tmp_dir"

close() {
    local pubKeyString="$(awk '{print $2}' ${tmp_dir}/ansible.pub)"
    ssh -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -o 'PasswordAuthentication=no' -i ${tmp_dir}/ansible "${SSH_USER}@${IP}" \
        'if test -f $HOME/.ssh/authorized_keys; then if grep -v "'${pubKeyString}'" $HOME/.ssh/authorized_keys > $HOME/.ssh/tmp; then cat $HOME/.ssh/tmp > $HOME/.ssh/authorized_keys && rm $HOME/.ssh/tmp; else rm $HOME/.ssh/authorized_keys && rm $HOME/.ssh/tmp; fi; fi' >/dev/null 2>&1
    rm -rf $tmp_dir
}
trap close SIGHUP SIGINT SIGTERM EXIT

ssh-keygen -a 100 -t ed25519 -f ${tmp_dir}/ansible -N "" -C ""
ssh-copy-id -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -i ${tmp_dir}/ansible.pub ${SSH_USER}@${IP}

cat >${tmp_dir}/inventory <<EOL
[archlinux]
archlinux-01 ansible_host=${IP} ansible_user=${SSH_USER} ansible_connection=ssh ansible_ssh_private_key_file=${tmp_dir}/ansible
EOL

echo "Installation configuration:"
cat ./playbooks/group_vars/*
echo -e "\n"

ansible-playbook \
    -i ${tmp_dir}/inventory \
    -K \
    ${PLAYBOOK}

[ $? -ne 0 ] && error "Installation failed"

echo -e "${GREEN}OK: Installation completed${NC}"
