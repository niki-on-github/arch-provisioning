#!/bin/bash

LBLUE='\033[1;34m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    cat <<EOF
Description:

    '`basename $0`' is a script to local provision arch linux

Dependecies:

    - ansible
    - python-pip

Usage:

    `basename $0` [PLAYBOOK]
EOF
    exit $1
}

error() {
    echo -e "${RED}ERROR: $1${NC}\n"
    usage 1
}

PLAYBOOK="$1"
[ -z "$PLAYBOOK" ] && error "Invalid arguments"
[ "$PLAYBOOK" = "-h" ] && usage 0
[ "$PLAYBOOK" = "--help" ] && usage 0
[ "$PLAYBOOK" = "help" ] && usage 0
[ -f "$PLAYBOOK" ] || error "Playbook not found"

sudo pacman -Sy --noconfirm --needed ansible python-pip
ansible-galaxy install -r requirements.yml

echo "Installation configuration:"
cat ./playbooks/group_vars/*
echo -e "--"

ansible-playbook -i ./inventory/localhost -K ${PLAYBOOK}

[ $? -ne 0 ] && error "Installation failed"

echo -e "${GREEN}OK: Installation complete${NC}"
