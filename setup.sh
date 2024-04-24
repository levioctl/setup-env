#!/bin/bash

# Determine package manager
COMMON_PACKAGES="tmux ipython3 xclip sshpass curl openssh-server"
OS=`grep ^NAME /etc/os-release | cut -d '=' -f 2`
OS=`sed -e 's/^"//' -e 's/"$//' <<<"$OS"`
if [ "$OS" = "Fedora" ]
then
    PACKAGES="
        htop
        python-devel
        vim-gtk3
        vim-X11
        cmake
        g++
    "
    PKG_MGR_CMD="sudo dnf install -y"
    # For VLC player
    dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
elif [ "$OS" = "Debian GNU/Linux" ] || [ "$OS" = "Ubuntu" ]
then
    PACKAGES="
        htop
        python3-dev
        vim-gtk3
        vim-gui-common
        cmatrix
        cmake
        g++
    "
    PKG_MGR_CMD="sudo apt install -y"

else
    echo "Error: Package manager was not found for OS '$OS'."
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

log "Configuring tmux"
cp {,~/.}tmux.conf
log "Configuring VIM..."
cp {,~/.}vimrc

if [ -d ~/.vim/bundle/Vundle.vim ]; then
mv ~/.vim/bundle/Vundle.vim ~/.vim/bundle/Vundle.vim.old
fi
exe-and-log-debug "git clone https://github.com/VundleVim/Vundle.vim.git `realpath ~/.vim/bundle/Vundle.vim`"
vim +PluginInstall +qall

#log "Installing textual-switcher..."
#if [ ! -d textual-switcher ]; then
#    git clone https://github.com/followerofmammon/textual-switcher
#fi
#cd textual-switcher
#git pull
#make install
#cd -

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
