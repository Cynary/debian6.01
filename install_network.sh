#!/usr/bin/env bash
apt-get install git -y

# Get files, and execute actual installer
# Get the files
REPO=`mktemp -d`
git clone http://github.com/Cynary/debian6.01 $REPO
cd $REPO
chmod +x install.sh
./install.sh
cd -
rm -fr $REPO
