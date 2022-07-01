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

add_i3_repo() {
    echo "Adding i3 repo to apt sources..."
    su -c "/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2022.02.17_all.deb keyring.deb SHA256:52053550c4ecb4e97c48900c61b2df4ec50728249d054190e8a0925addb12fc6" $SUDO_USER
    dpkg -i ./keyring.deb
    echo "deb [arch=amd64] http://debian.sur5r.net/i3/ focal universe" > /etc/apt/sources.list.d/sur5r-i3.list
    rm ./keyring.deb
}

install_dependencies() {
    echo -e "\nInstalling dependencies..."
    apt-get update
    apt-get install -y \
        i3 \
        brightnessctl \
        nitrogen \
        numlockx \
        xss-lock \
        flameshot \
        imagemagick \
        locate

    echo -e "\nUpdating locate db..."
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
    echo -e "\nRemoving existing config dirs..."
    
    _remove_dir $I3_DIR
    _remove_dir $I3STATUS_DIR
}

create_config_symlinks() {
    echo -e "\nCreating config symlinks..."
    
    ln -s $PROJECT_DIR/i3 $I3_DIR 
    ln -s $PROJECT_DIR/i3status $I3STATUS_DIR

    _replace_symlink $PROJECT_DIR/scripts/enforce_gnome_keyring.conf $KEYRING_CONF 
    _replace_symlink $PROJECT_DIR/scripts/enforce_gnome_keyring.py $KEYRING_SCRIPT
    _replace_symlink $PROJECT_DIR/scripts/100after-install $APT_HOOK
}

update_desktop_files() {
    echo -e "\nUpdating .desktop files using enforce_gnome_keyring script..."

    python3 $KEYRING_SCRIPT --no-backup --config $KEYRING_CONF
}

add_i3_repo
install_dependencies
remove_existing_config_dirs
create_config_symlinks
update_desktop_files

echo "DONE!"
