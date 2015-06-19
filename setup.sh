#!/bin/bash

# Determine package manager
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)
if [[ ! -z $YUM_CMD ]]; then
INITIAL_PACKAGES="python python-devel python-setuptools openssh-server"
PKG_MGR_CMD="sudo yum install -y"
ANSIBLE_PLAYBOOK_FILE="yum-playbook.yaml"
elif [[ ! -z $APT_GET_CMD ]]; then
INITIAL_PACKAGES="python python-dev python-setuptools openssh-server"
PKG_MGR_CMD="sudo apt install -y"
ANSIBLE_PLAYBOOK_FILE="apt-playbook.yaml"
else
    echo "Error: Package manager was not found."
    exit 1;
fi

export LOG_FILE="/tmp/setup.log"

echo "Run this without 'source'."
# End script if any command fails
set -e

function log {
	echo $1 | tee -a $LOG_FILE
}

function exe-and-log-debug {
	$1 &>> $LOG_FILE
}

echo -n > $LOG_FILE

# Configure global git configuration that may not be configured
export _params="user.name user.email"
for _param in $_params; do
	export _cmd="git config --global $_param"
	export _val=`$_cmd`
	if [ "$_val" = "" ]; then
		log "Enter a global $_param for git (or press Enter to skip)"
		read _username
		$_cmd "$_username"
	fi
done


# Pretty git branch graphs
log "Configuring graphic logs in git..."
git config --global alias.lg1 "log --graph --abbrev-commit --decorate --date=relative --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
git config --global alias.lg2 "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
git config --global alias.lg \!"git lg1"

log "More bash configurations..."
export result=`grep "show-all-if-ambiguous" ~/.bashrc`
if [ "$result" = "" ]; then
	echo "bind 'set show-all-if-ambiguous on'" >> ~/.bashrc
fi
export result=`grep "history-search-backward" ~/.bashrc`
if [ "$result" = "" ]; then
	echo "bind '\"\e[A\": history-search-backward'" >> ~/.bashrc
	echo "bind '\"\e[B\": history-search-forward'" >> ~/.bashrc
fi
source $HOME/.bashrc || true

# Install only what's necessary to use ansible
echo "Full log will be written to '$LOG_FILE'."
for _package in $INITIAL_PACKAGES; do
	log "Installing $_package"
	exe-and-log-debug "$PKG_MGR_CMD $_package"
done
log "Installing pip..."
exe-and-log-debug "sudo easy_install pip"
log "Installing ansible..."
exe-and-log-debug "sudo pip install ansible"

# Ansible's hosts file
sudo mkdir /etc/ansible || true
log "Creating Ansible's hosts file..."
sudo sh -c 'echo "[local]\n127.0.0.1" > /etc/ansible/hosts ansible_connection=local'

log "Installing packages using ansible..."
exe-and-log-debug "sudo ansible-playbook -s $ANSIBLE_PLAYBOOK_FILE -vvvvv"

log "Copying tmux configuration file..."
cp {,~/.}tmux.conf
log "Configuring VIM..."
cp {,~/.}vimrc
if [ ! -d "$HOME/.vim" ]; then
    mkdir ~/.vim
fi
if [ ! -d "$HOME/.vim/bundle" ]; then
    mkdir ~/.vim/bundle
fi
if [ ! -d "$HOME/.vim/bundle/ctrlp.vim" ]; then
    git clone https://github.com/kien/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim
fi
if [ ! -d "$HOME/.vim/bundle/vim-bling" ]; then
    git clone https://github.com/ivyl/vim-bling ~/.vim/bundle/vim-bling
fi

log "Done."
