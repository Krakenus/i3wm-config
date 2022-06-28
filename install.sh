#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Run this with sudo."
    exit 0
fi

if [[ -z $SUDO_USER ]]; then
    echo "Run this with sudo as regular user, not root."
    exit 0
fi

PROJECT_DIR=$(dirname $(realpath $0))
I3_DIR=/home/$SUDO_USER/.config/i3
I3STATUS_DIR=/home/$SUDO_USER/.config/i3status
KEYRING_CONF=/etc/enforce_gnome_keyring.conf
KEYRING_SCRIPT=/usr/local/bin/enforce_gnome_keyring.py
APT_HOOK=/etc/apt/apt.conf.d/100after-install

install_dependencies() {
    echo "Installing dependencies..."
    apt-get install -y \
        i3 \
        brightnessctl \
        nitrogen \
        numlockx \
        xss-lock \
        flameshot \
        imagemagick \
        locate

    echo "Updating locate db..."
    updatedb
}

_remove_dir() {
    if [[ -d $1 ]]; then
        rm -rf $1
    fi
}

_replace_symlink() {
    target=$1
    link_path=$2

    if [[ -e $link_path ]]; then
        rm $link_path
    fi
    ln -s $target $link_path
}

remove_existing_config_dirs() {
    echo "Removing existing config dirs..."
    
    _remove_dir $I3_DIR
    _remove_dir $I3STATUS_DIR
}

create_config_symlinks() {
    echo "Creating config symlinks..."
    
    ln -s $PROJECT_DIR/i3 $I3_DIR 
    ln -s $PROJECT_DIR/i3status $I3STATUS_DIR

    _replace_symlink $PROJECT_DIR/scripts/enforce_gnome_keyring.conf $KEYRING_CONF 
    _replace_symlink $PROJECT_DIR/scripts/enforce_gnome_keyring.py $KEYRING_SCRIPT
    _replace_symlink $PROJECT_DIR/scripts/100after-install $APT_HOOK
}

update_desktop_files() {
    echo "Updating .desktop files using enforce_gnome_keyring script..."

    python3 $KEYRING_SCRIPT --no-backup --config $KEYRING_CONF
}

install_dependencies
remove_existing_config_dirs
create_config_symlinks
update_desktop_files

echo "DONE!"
