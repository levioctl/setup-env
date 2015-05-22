#!/bin/bash
# End script if any command fails
PKG_MGR_CMD="sudo apt-get install -y"

echo "Run this without 'source'."
set -e
export LOG_FILE="/tmp/setup.log"
INITIAL_PACKAGES="python python-dev python-setuptools"
echo -n > $LOG_FILE
echo "Full log will be written to '$LOG_FILE'."
for package in $INITIAL_PACKAGES; do
	echo "Installing $package" | tee -a $LOG_FILE
	$PKG_MGR_CMD $package &>> $LOG_FILE
done
echo "Installing pip..." | tee -a $LOG_FILE
sudo easy_install pip &>> $LOG_FILE
echo "Installing ansible..." | tee -a $LOG_FILE
sudo pip install ansible &>> $LOG_FILE

# Ansible's hosts file
sudo mkdir /etc/ansible || true
echo "Creating Ansible's hosts file..." | tee -a $LOG_FILE
sudo sh -c 'echo "[local]\n127.0.0.1" > /etc/ansible/hosts'
echo Done. | tee -a $LOG_FILE

