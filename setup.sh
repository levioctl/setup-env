#!/bin/bash

# Determine package manager
YUM_CMD=$(which yum)
APT_GET_CMD=$(which apt-get)
if [[ ! -z $YUM_CMD ]]; then
INITIAL_PACKAGES="python python-devel python-setuptools openssh-server curl"
PKG_MGR_CMD="sudo yum install -y"
ANSIBLE_PLAYBOOK_FILE="yum-playbook.yaml"
elif [[ ! -z $APT_GET_CMD ]]; then
INITIAL_PACKAGES="python python-dev python-setuptools openssh-server curl"
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
export result=`grep "function dup " ~/.bashrc`
if [ "$result" = "" ]; then
	echo "function dup { echo -n \$1 | xclip -sel clip; }" >> ~/.bashrc
fi
source $HOME/.bashrc || true

export result=`grep "cd.." ~/.bashrc`
if [ "$result" = "" ]; then
    echo "alias cd..=\"cd ..\"" >> ~/.bashrc
fi

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
log "Configuring Vrapper..."
cp {,~/.}vrapperrc
if [ ! -d "$HOME/.vim" ]; then
    mkdir ~/.vim
fi
if [ ! -d "$HOME/.vim/bundle" ]; then
    mkdir ~/.vim/bundle
fi
if [ ! -d "$HOME/.vim/autoload" ]; then
    mkdir ~/.vim/autoload
    curl -LSso .vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi
if [ ! -d "$HOME/.vim/bundle/ctrlp.vim" ]; then
    git clone https://github.com/kien/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim
fi
if [ ! -d "$HOME/.vim/bundle/vim-bling" ]; then
    git clone https://github.com/ivyl/vim-bling ~/.vim/bundle/vim-bling
fi
if [ ! -d "$HOME/.vim/bundle/grep" ]; then
    git clone http://github.com/yegappan/grep ~/.vim/bundle/grep
fi
if [ ! -d "$HOME/.vim/bundle/jedi-vim" ]; then
    git clone https://github.com/davidhalter/jedi-vim ~/.vim/bundle/jedi-vim
fi
if [ ! -d "$HOME/.vim/bundle/vim-flake8" ]; then
    git clone https://github.com/nvie/vim-flake8 ~/.vim/bundle/vim-flake8
fi
if [ ! -d "$HOME/.vim/bundle/vim-surround" ]; then
    git clone https://github.com/nvie/vim-surround ~/.vim/bundle/vim-surround
fi
log "Copying flake8 configuration file..."
mkdir -p ~/.config
cp {,~/.config/}flake8
log "Installing textual-switcher..."
cd `mktemp -d`
git clone https://github.com/followerofmammon/textual-switcher
cd textual-switcher
make install

log "Disabling visual effects in GNOME..."
gsettings set org.gnome.desktop.interface enable-animations false
dconf write /org/gnome/settings-daemon/plugins/remote-display/active false
dconf write /org/gnome/desktop/interface/enable-animations false

log "Setting items list view as default in Nautilus..."
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

log "Disabling whoopsie in case it exists..."
sudo systemctl stop whoopsie || true
sudo systemctl disable whoopsie || true

log "Disabling lockscreen..."
dconf write /org/gnome/desktop/lockdown/disable-lock-screen true

log "Disabling the Caps Lock button..."
xmodmap -e "keycode 66 = Shift_L NoSymbol Shift_L" || true

log "Making sure rhythmbox is not installed..."
sudo apt-get remove rhythmbox || true

log "Done."
log "Stuff to do manually:"
log "* Install the no-topleft corner GNOME plugin"
log "* Enable the places status indicator GNOME plugin"
