#!/bin/bash
PKG_MGR_CMD="sudo apt-get install -y"

echo "Run this without 'source'."
# End script if any command fails
set -e

# Configure global git configuration that may not be configured
export _params="user.name user.email"
for _param in $_params; do
	export _cmd="git config --global $_param"
	export _val=`$_cmd`
	if [ "$_val" = "" ]; then
		echo "Enter a global $_param for git (or press Enter to skip)"
		read _username
		$_cmd "$_username"
	fi
done

# Pretty git branch graphs
echo "Configuring graphic logs in git..." | tee -a $LOG_FILE
git config --global alias.lg1 "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
git config --global alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
git config --global alias.lg \!"git lg1"

# Install only what's necessary to use ansible
export LOG_FILE="/tmp/setup.log"
INITIAL_PACKAGES="python python-dev python-setuptools openssh-server"
echo -n > $LOG_FILE
echo "Full log will be written to '$LOG_FILE'."
for _package in $INITIAL_PACKAGES; do
	echo "Installing $_package" | tee -a $LOG_FILE
	$PKG_MGR_CMD $_package &>> $LOG_FILE
done
echo "Installing pip..." | tee -a $LOG_FILE
sudo easy_install pip &>> $LOG_FILE
echo "Installing ansible..." | tee -a $LOG_FILE
sudo pip install ansible &>> $LOG_FILE

# Ansible's hosts file
sudo mkdir /etc/ansible || true
echo "Creating Ansible's hosts file..." | tee -a $LOG_FILE
sudo sh -c 'echo "[local]\n127.0.0.1" > /etc/ansible/hosts ansible_connection=local'

echo "Installing packages using ansible..." | tee -a $LOG_FILE
sudo ansible-playbook -s apt-playbook.yaml -vvvvv &>> $LOG_FILE
echo "Done." | tee -a $LOG_FILE
