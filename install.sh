#!/usr/bin/env bash
apt-get install firmware-iwlwifi emacs-nox dhcpcd5 git build-essential tmux libpam-krb5 -y
apt-get remove wicd -y
apt-get autoremove -y

systemctl enable dhcpcd
echo "alias python=python3" >> /etc/bash.bashrc

cp -R --no-preserve=all slash/* /
