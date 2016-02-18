#!/usr/bin/env bash
apt-get install emacs-nox dhcpcd5 git build-essential tmux libpam-krb5 -y
apt-get remove wicd -y
apt-get autoremove -y

systemctl enable dhcpcd
echo "alias python=python3" >> /etc/bash.bashrc

# Special added files+directory
function install() {
    cp -r slash$1 $1
    if [[ $# > 1 ]]
    then
	chmod -R $2 $1
    fi
    chown -R 0:0 $1
}
install /etc/pam.d/pam_exec.d 755
install /lib/firmware/iwlwifi-1000-5.ucode 755
install /usr/share/X11/xorg.conf.d/20-thinkpad.conf 644
install /etc/skel
install /etc/wpa_supplicant/wpa_supplicant.conf

for f in `find slash -type f | cut -d'/' -f2-`
do
    if [ ! -e /$f ]
    then
	echo "Invalid file /$f"
	exit 1
    fi
    PERMS=`stat -c "%a" /$f`
    OWNER=`stat -c "%u" /$f`
    GROUP=`stat -c "%g" /$f`
    cp -R --no-preserve=all slash/$f /$f
    chmod $PERMS /$f
    chown $OWNER:$GROUP /$f
done

update-grub

# Install orifs
# apt-get install scons pkg-config libboost-dev uuid-dev libfuse-dev libevent-dev libssl-dev -y
# wget https://bitbucket.org/orifs/ori/downloads/ori-0.8.1.tar.xz
# tar jvxf ori-0.8.1.tar.xz
# cd ori-0.8.1
# scons
# scons PREFIX=/usr/local install
