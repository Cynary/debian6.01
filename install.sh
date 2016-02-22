#!/usr/bin/env bash

################################################################################
# Utilities
function fail() {
    echo Failed: $1
    exit 1
}
function install() {
    rm -rf $1
    cp -r slash$1 $1 || fail "Installing $1"
    if [[ $# > 1 ]]
    then
	chmod -R $2 $1
    fi
    chown -R 0:0 $1
}
################################################################################

################################################################################
# Basic packages to install/remove
apt-get update -y || fail "Update"
apt-get upgrade -y || fail "Upgrade"

apt-get install emacs-nox dhcpcd5 git build-essential tmux libpam-krb5 \
	krb5-user -y || fail "Package install"

apt-get remove wicd -y \
    || fail "Package removal" # No need for this network manager

# Remove any lingering useless packages
apt-get autoremove -y || fail "Package removal"
################################################################################

################################################################################
# Install orifs
# Build/runtime dependencies
apt-get install scons pkg-config libboost-dev uuid-dev libfuse-dev \
	libevent-dev libssl-dev fuse libedit-dev ntp openssh-server -y

# Servers need to have time synchronized for everything to work
systemctl enable ntp

# Clone the repo and build
ORI_REPO=`mktemp -d`
git clone http://bitbucket.org/orifs/ori.git $ORI_REPO
cd $ORI_REPO
scons
scons PREFIX=/usr/local install
cd -
rm -fs $ORI_REPO

# This user will be the one to use orifs
useradd orifs_user -d /etc/601/ori -s `which bash`
################################################################################

################################################################################
# Special added files+directories
install /etc/pam.d/pam_exec.d 755 # Create/clean user scripts
install /lib/firmware/iwlwifi-1000-5.ucode 755 # network firmware
install /usr/share/X11/xorg.conf.d/20-thinkpad.conf 644 # trackpad/trackpoint
install /etc/skel # Home skeleton
install /etc/wpa_supplicant/wpa_supplicant.conf # MIT configuration
install /etc/601 755 # 6.01 specific files (e.g. background/scripts)
install /etc/601/ori/.ssh 700 # ORIFS keys
install /etc/601/ori/.ssh/authorized_keys 600 # ORIFS keys
chown orifs_user:orifs_user -R /etc/601/ori # Make orifs_user control it
################################################################################

################################################################################
# Install lib601
apt-get install idle3 python3-numpy python3-matplotlib -y
PWD=`pwd`
cd /etc/601/scratch
wget -N http://sicp-s4.mit.edu/laptops/files/lib601.tar.gz
tar -zxf lib601.tar.gz
cd lib601-*
python3 setup.py install
cd ..
rm -rf lib601-*
cd $PWD
################################################################################

################################################################################
# Replicate file structure for the system
for f in `find slash -type f | cut -d'/' -f2-`
do
    [ -e /$f ] || fail "Invalid file /$f"
    PERMS=`stat -c "%a" /$f`
    OWNER=`stat -c "%u" /$f`
    GROUP=`stat -c "%g" /$f`
    cp -R --no-preserve=all slash/$f /$f
    chmod $PERMS /$f
    chown $OWNER:$GROUP /$f
done
################################################################################

# Network magic - aggressively gets new IPs/DNS on all interfaces
systemctl enable dhcpcd

# Now everyone has python3
echo "alias python=python3" >> /etc/bash.bashrc

# Remove grub delay and add background
update-grub

# These services caused delays on shutdown, disabling them
systemctl mask alsa-restore.service alsa-store.service


echo "To finish the install you need to reboot. Press [ENTER] when ready"
read -n
systemctl reboot
