#!/usr/bin/env bash
apt-get install emacs-nox dhcpcd5 git build-essential tmux libpam-krb5 -y
apt-get remove wicd -y
apt-get autoremove -y

systemctl enable dhcpcd
echo "alias python=python3" >> /etc/bash.bashrc

# Special added files+directory
cp -r slash/etc/pam.d/pam_exec.d /etc/pam.d
chmod 755 /etc/pam.d/pam_exec.d/*
chown -R 0:0 /etc/pam.d/pam_exec.d

cp slash/lib/firmware/iwlwifi-1000-5.ucode /lib/firmware
chmod 755 /lib/firmware/iwlwifi-1000-5.ucode
chown -R 0:0 /lib/firmware/iwlwifi-1000-5.ucode

cp slash/usr/share/X11/xorg.conf.d/20-thinkpad.conf /usr/share/X11/xorg.conf.d
chmod 644 /usr/share/X11/xorg.conf.d/20-thinkpad.conf
chown 0:0 /usr/share/X11/xorg.conf.d/20-thinkpad.conf

cp -r slash/etc/skel /etc
chown 0:0 -R /etc/skel

for f in `find slash -type f | cut -d'/' -f2-`
do
    PERMS=`stat -c "%a" /$f`
    OWNER=`stat -c "%u" /$f`
    GROUP=`stat -c "%g" /$f`
    cp -R --no-preserve=all slash/$f /$f
    chmod $PERMS /$f
    chown $OWNER:$GROUP /$f
done
