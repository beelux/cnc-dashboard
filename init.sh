#!/usr/bin/env bash

generateKey() {
	touch sshKey
	touch sshKey.pub
	rm sshKey
	rm sshKey.pub
	ssh-keygen -t ed25519 -f ./sshKey -q -N "" -C ""
}

deployKey() {
	sshpass -p alarm ssh-copy-id -i ./sshKey.pub -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=false alarm@"$1"
}

# If keys are present, we just need to deploy it and destroy the SSH Agent
# Otherwise, we genrate a key and then deploy it
# The key can be present on the remote host multiple times,
# -> not a big issue, just not clean, but it works
[ -e sshKey ] && [ -e sshKey.pub ] || generateKey


for remoteHost in "$@"
do
    echo "$remoteHost"
    deployKey "$remoteHost"
done

export SSH_AUTH_SOCK=/dev/null
