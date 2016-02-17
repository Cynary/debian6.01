#!/usr/bin/env bash
#apt-get install firmware-iwlwifi emacs-nox dhcpcd5 git build-essential tmux libpam-krb5 -y
#apt-get remove wicd -y
#apt-get autoremove -y

#systemctl enable dhcpcd
#echo "alias python=python3" >> /etc/bash.bashrc

# Special added files+directory
cp -r slash/etc/pam.d/pam_exec.d /etc/pam.d
chmod 755 /etc/pam.d/pam_exec.d/*
chown -R 0:0 /etc/pam.d/pam_exec.d

for f in `find slash -type f | cut -d'/' -f2-`
do
    PERMS=`stat -c "%a" /$f`
    OWNER=`stat -c "%u" /$f`
    GROUP=`stat -c "%g" /$f`
    echo $f $PERMS $OWNER $GROUP
    cp -R --no-preserve=all slash/$f /$f
    chmod $PERMS /$f
    chown $OWNER:$GROUP /$f
done
