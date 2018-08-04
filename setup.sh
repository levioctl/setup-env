#!/bin/bash

# Determine package manager
COMMON_PACKAGES="python python-setuptools tmux ipython firefox xclip sshpass curl openssh-server"
OS=`grep ^NAME /etc/os-release | cut -d '=' -f 2`
OS=`sed -e 's/^"//' -e 's/"$//' <<<"$OS"`
if [ "$OS" = "Fedora" ]
then
    PACKAGES="
        python-devel
        vim
        vim-X11
        cmake
        llvm
        gcc
        vlc
        fzf
	python-pip
    "
    PKG_MGR_CMD="sudo dnf install -y"
    SERVICE_FILES_DIR=/usr/lib/systemd/system/
    # For VLC player
    dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
elif [ "$OS" = "Ubuntu" ]
then
    PACKAGES="
        python-dev
        vim-gtk
        vim-gui-common
        cmatrix
        cmake
        llvm
        gcc
	python-pip
    "
    PKG_MGR_CMD="sudo apt install -y"
    SERVICE_FILES_DIR=/lib/systemd/system/
    # The following repo is required for vim-gtk
    # taken from http://askubuntu.com/questions/775059/vim-python-support-on-ubuntu-16-04
#sudo add-apt-repository -y ppa:pi-rho/dev
#sudo apt-get -y update
else
    echo "Error: Package manager was not found."
    exit 1;
fi
PIP_PACKAGES="
    mock
    pep8
    jedi
    flake8
"
export LOG_FILE="/tmp/setup.log"

echo "Run this without 'source'."
# End script if any command fails
set -e

function log {
	echo $1 | tee -a $LOG_FILE
}

function exe-and-log-debug {
	echo $1 | tee -a $LOG_FILE
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

echo "Full log will be written to '$LOG_FILE'."
for _package in $COMMON_PACKAGES $PACKAGES; do
	log "Installing package '$_package'..."
	exe-and-log-debug "$PKG_MGR_CMD $_package"
done
#log "Installing pip..."
#exe-and-log-debug "sudo easy_install pip"
#for _package in $PIP_PACKAGES; do
#	log "Installing PIP package '$_package'..."
#	exe-and-log-debug "sudo pip install $_package --upgrade"
#done

log "Configuring tmux"
cp {,~/.}tmux.conf
log "Configuring VIM..."
cp {,~/.}vimrc
log "Configuring Vrapper..."
cp {,~/.}vrapperrc

mkdir -p ~/.vim
mkdir -p ~/.vim/bundle
mkdir -p ~/.vim/after

function install-vim-plugin {
    PLUGIN_DIR="$HOME/.vim/bundle/$2"
    if [ ! -d "$PLUGIN_DIR" ]; then
        git clone https://github.com/$1/$2 ~/.vim/bundle/$2
    else
        exe-and-log-debug "cd $PLUGIN_DIR"
        exe-and-log-debug "git fetch origin"
        exe-and-log-debug "git checkout -f origin/master"
        exe-and-log-debug "cd -"
    fi
    cp -rf ~/.vim/bundle/$2/after/* ~/.vim/after/ || true
}

install-vim-plugin kien ctrlp.vim
install-vim-plugin ivyl vim-bling
install-vim-plugin yegappan grep
install-vim-plugin davidhalter jedi-vim
install-vim-plugin nvie vim-flake8
install-vim-plugin nvie vim-surround
install-vim-plugin kien rainbow_parentheses.vim
install-vim-plugin tpope vim-fugitive
install-vim-plugin ervandew supertab
install-vim-plugin kevinw pyflakes-vim
install-vim-plugin scrooloose nerdtree

log "Copying flake8 configuration file..."
mkdir -p ~/.config
cp {,~/.config/}flake8
log "Installing textual-switcher..."
if [ ! -d textual-switcher ]; then
    git clone https://github.com/followerofmammon/textual-switcher
fi
cd textual-switcher
git pull
make install
cd -

log "Installing workspaces"
if [ ! -d workspaces ]; then
    git clone https://github.com/followerofmammon/workspaces
fi
cd workspaces
git pull
cd -

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

log "Creating music shortcut (C-n)..."
mkdir -p ~/commands
cp music.sh ~/commands/
export result=`grep "music" ~/.bashrc`
if [ "$result" = "" ]; then
    echo "alias music='~/commands/music.sh >2 /dev/null'" >> ~/.bashrc
fi
export result=`grep "music" ~/.inputrc`
if [ "$result" = "" ]; then
    touch ~/.inputrc
    echo '"\C-n": "music\C-m"' >> ~/.inputrc
fi

log "Setting up keybindings for ctrl+left and ctrl+right in bash since they don't exist on some OSs"
export result=`grep "forward-word" ~/.inputrc`
if [ "$result" = "" ]; then
    cat inputrc_keybindings >> ~/.inputrc
fi

log "Stuff to do manually:"
log "* Install the no-topleft corner GNOME plugin"
log "* Enable the places status indicator GNOME plugin"
