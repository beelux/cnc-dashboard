#!/usr/bin/env bash
ansible-galaxy install -r requirements.yml

if [ -z ${1+x} ]; then
	echo "var is unset"; 
	PLAYBOOK=site.yml
else
	PLAYBOOK=$1
fi

# Agent running causes issues because SSH seems to prioritise those keys by default
SSH_AUTH_SOCK=/dev/null
ansible-playbook -v -i hosts.yml $PLAYBOOK
