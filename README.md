Debian for 6.01
===============

Software distribution for setting up Debian Stable (8.3.0 Jessie) on the 6.01 class laptops.

Installing
----------

Installing is simple. You simply have to run the *install.sh* script as root:

```bash
chmod +x install.sh
sudo ./install.sh
```

If you want a lighter weight installer to move around, use our network installed:

```bash
chmod +x install_network.sh
sudo ./install_network.sh
```

This one can be sent without the rest of this repository. It will do the same thing as *install.sh*,
except it will also clone the repository.

Overview
--------

Here's a simple overview of what `install.sh` does:

1. Install useful packages
  * *emacs-nox*
  * *tmux*
  * *build-essential*
  * *git*

   Not necessarily used by the students, but potentially useful for staff

2. Install necessary packages
  * *dhcpcd5*

     This packages is networking magic, dhcpcd will
     aggressively try to reconnect to any configured network on any interface.

  * *libpam-krb5*

     Allows us to use kerberos logins. This will be used in the PAM files

3. Remove unnecessary packages
  * *wicd*

   Might find other packges to remove, this is a **WORK IN PROGRESS**

4. Autoremove any other unused packages

5. Install ORIFS
  * Build + Runtime dependencies from debian sources
  * Enables NTP (for ori to work servers need to be close in time)
  * ORI from repository
  * Adds a user to manage ORI repos

    OriFS will keep the student's files in sync across laptops.

6. Install new files

   A lot of new files are needed for this system, this step just puts them in their positions:
   
  * pam_exec.d files for login/logout scripts
  * wireless firmware
  * Thinkpad trackpad/trackpoint configuration
  * Nice home skeleton for the users
  * wpa_supplicant configuration to work with MIT (**WORK IN PROGRESS** what other networks?)
  * 601 specific files (background/scripts)
  * *orifs_user*'s home directory and SSH keys. Also change ownership of it.

7. Copy files to their positions

   Via the application of a lot of magic (next section explains that magic in some detail) we have a small list of files that need to be modifed
   in a default Debian Jessie system. This step just puts those files in their respective positions (the structure is replicated in this repo).
   This step also sets the correct permissions.

8. Enable *dhcpcd*

   The *dhcpcd* service aggressively tries to get DHCP information from every interface. This is what allows the network to reliably stay on in these laptops.

9. Set python as a global *alias* for *python3*. That way, when a student types `python` in the terminal, they will get the `python3` terminal.

   **WORK IN PROGRESS** Debian Stable still has python2 as default, need to check if this will interfere in any way with lib601.

10. Update grub

   One of the files we copied was the grub configuration file. This new config file sets the timeout to 0, so we don't have to wait at the load screen.
   It does, however, require that we call `update-grub`

11. Disable some alsa services that slowed down reboot a lot.

11. Reboot to apply all changes

The Magic
---------

### Network

The firmware is stored in a file, and that way we avoid having to add non-free repos to download it.

The dhcpcd service agressively tries to renew connections. It won't, however, start if the interfaces in /etc/network/interfaces are setup to
use a dhcp client already. This file simply adds the wireless network interface (this causes it to start on system startup, and try to connect
to a specific SSID configured to be used by wpa_supplicant) and undoes all the damage done by the dhcp parameter every tutorial mindlessly adds
at the end (we instead just add manual). The network configuration is all done in */etc/wpa_supplicant/wpa_supplicant.conf* and other networks
can be added, even if they are WPA/WPA2 networks. The guide at [this ubuntu forums thread][wireless] was followed to set this up (it turns out
that the only way to get reliable wireless is to rely on wpa_supplicant - using the interfaces file was attempted, but did not work out).

### Kerberos login

The *krb5.conf* simply adds a `forwardable = true` line to the file, so that you can forward tickets, and more easily login to dialup.

**WORK IN PROGRESS** we might use the tickets when we have a new file synchronization mechanism. We might also do it automatically (a la firefox
certificate stealing, look [here][arch601] for that example).

To also get Kerberos login to work, we had to modify the PAM files. The part that allowed the login to actually happen was mostly there, but it only worked if there was already a user. If that were not true, the login would fail. Modifications from a [previous project][arch601] were used, although they were and will remain largely undocumented. To better control what users get created and make sure no extra users were left on the system, we did some modifications based on the information [here][pam_unsuccessful_login], [here][pam_guide], and [here][pam_exec_man].

**BE VERY CAREFUL MAKING CHANGES LIKE THIS**. A small mistake during development caused the system to delete every user in the system along with every home directory. The original draft for this project lived in that original system. The files were all recovered thanks to file recovery programs but it was an unpleasant experience.

The current login flow looks like:
If local login fails, but kerberos login succeeds create a new user, along with a home directory for the user. (createUser and pam_mkhomedir do this).
When a logout happens, as long as it's not one of the specified system users (root, alpha, beta, or orifs_user), then the user gets deleted along with all their files. (this is done in cleanUser).

**WORK IN PROGRESS** instead let's set up a file flagging whether it was a kerberos login or a system login. All the files will also not get deleted in the future, as they are simply synchronized with ori.

### Skeleton home directory

This contains a bunch of nice defaults for LXDM that every student will have.

Overview of changes:
* Visual
  * Task Bar aesthetics improved
  * Removed some of the applets (desktop, CPU usage, ...)
* One desktop by default (in the *openbox* configuration file under `.config/openbox`)
* [CTRL+ALT+T shortcut][keybind]
* 6.01 Background
* 6.01 icon for taskbar menu
* Adding volume control applet and enabling media buttons
* Have SSH automatically delegate kerberos tickets
* Not using GIMP for opening image files by default, instead use image viewer
* Opening the terminal automatically on login
* Setting up autostart to run a script called login.sh in case we need to do updates on login, or to the directory/file structure.

**WORK IN PROGRESS** applications on the desktop, ... all are needed.

### Miscelaneous Configuration changes

There's a few miscelaneous changes with the objective of making the experience better:
* Making DuckDuckGo the default search engine rather than Yahoo
* Setting up the lightdm greeter to use the 6.01 background
* Making sue the greeter does not display a user list.

### */etc/601*

**WORK IN PROGRESS** need to put an updater script here, and configure systemd to use it; also need to put lib601 installer here; need to setup orifs + encfs.

This special directory contains 6.01-specific files:
* *wallpaper.svg* - background for greeter+desktop
* *login.sh* - run automatically on login
* *ori/* - home directory for *orifs_user*; will store ssh keys here, and ori repos.

#### */etc/601/ori/*

The *ori/* directory is the home for *orifs_user*. This contains the ssh keys necessary for ori replication and will also contain all the encrypted home directories of kerberos users. This will allow students to login and retrieve data they worked on other machines.

When a user logs in, the PAM scripts check if they ever logged in. If yes, then the ori repo is replicated and encFS is used to mount it as their home directory. Otherwise a new ori repo is setup, created as an encrypted directory, mounted in their home directory, and the contents of */etc/skel* copied there.

**TODO**: to decide whether each student should have their own orifs system, or whether to store them all in the same system. If they have their
own, then the first step post login is to try and mount it, which could be bad if the network is down.

The general procedure to do this was taken from [here][encfssetup].

### Thinkpad configuration

Special configuration files to enable thinkpad features. Look [here][debiantrack] for the procedure used to enable trackpoint scrolling.
Look [here][debiantap] for the documentation on how to enable tap to click.

The laptop just works out of the box otherwise, except for the necessary setup of the trackpad + trackpint.

### GRUB

Changing /etc/default/grub allows you to configure grub differently. We simply remove the timeout. After that, all that is requires is to call `update-grub`. We also make the background for grub to be the 6.01 wallpaper image as described [here][grubbg].

Ori File System
---------------

[link][oripage], [link][oriinstall], [link][oripaper], [source][oridl].

Notes:

This is really annoying to setup. First, everyone must be able to ssh to each other with no issues, which means a lot of key sharing. I believe the safest way to go about this is to have one underprivileged user on all systems whose job is to just be the orifs "talker". This user must be the one to setup orisync with orisync init (**MAKE SURE TO CALL ORISYNC INIT**), create the repos with ori: `ori newfs repo-name` on the first system and `ori replicate --shallow USER@HOST:repo-name repo-name`, and mount them: `orifs repo-name`.
**NOTE**: orisync MUST be started before orifs is called to mount the repo, otherwise everything fails. Recommend that this is put in a startup script somehow. NOTE: orisync must be setup to track the repos, but their location is weird: always `~/.ori/repo-name.ori/`.

So, an example setup looks like:
### Remote system

Separately run `orisync` init and configuration. You should be able to just generate the file structure for `orisync` separately. Interestingly, it seems the key is always the same. Maybe we can have a more secure key by just generating it ourselves separately.
Make sure that this user's ssh key is installed in the local system. Make sure there is an ssh server running.

`bash
ori newfs $REPO # Adds filesystem to repo list
mkdir $REPO # we're mounting it here
orisync # starts orisync
orifs $REPO # mounts repo
`

### Local system

Same story about `orisync` init and possibly using directory+file structure to do everything. Make sure that your public key is in the remote system and that there is an ssh server running locally as well.

`bash
ori replicate --shallow $USER@$REMOTE:$REPO
mkdir $REPO
orisync
orifs $REPO
`

More notes: use `orisync hostadd` to make sure laptops look for sicp-s4 at all times. Otherwise, they will look for local network machines (which is not terrible in itself). It seems that `orisync` will go into a weird undescribed state if the file system is already mounted when you start orisync. Make sure to mount the file system with `orifs` **AFTER** launching `orisync`

### SSH configuration notes

The easiest way to set this up seems to be:
* Create a user in the local machines (e.g. orifs_user)
* Make their home directory the place where the repos are going to live (one for each user's encrypted home)
* Setup the ssh server in the local machines to only allow login as orifs_user
* Setup the ssh server in the local machines to only allow key based login
* Setup the ssh server in the local machines to do a chroot jail on orifs_user to its home directory
* Setup the key to connect to the server, and accept the same key (that way we have ONE key file for all the ORI stuff - simplifies things, and users are unprivileged enough that if that key gets leaked it's not a major security issue -- everything's encrypted anyway, it's easy enough to rollout a new key everywhere, and the local users of the machines don't have access to that file).
* Create a user in the server that's chrooted and can only be logged in to via key login.
* Set it up to both use and accep the ORI keypair.
* Run orisync init etc. on the server as the user to setup the cluster.
* Run orisync init on the machines to join them to the cluster (this can be done via config files already present on the machines, perhaps, although we need some way to generate machine IDs)
* Through ssh, the local machines are able to add repositories and then locally they can clone them.
* Add the main server to the static hosts of the local machines.
* Let the fun begin :)

Note2: chroot_jail might not work :/ Make sure to setup AllowUser in the local machine. Perhaps we can use a different chroot_jail with only ori installed? Or a different server altogether for file storage?

Note3: orifs mounts without allowing access to other users by default. Seems easy to modify, I feel it's time to fork it.

TODO
----

* Move repository to AFS, and fix install_network.sh appropriately
* Setup a good way to update lib601
* Setup a good way to push updates to students (most likely we'll have a changing skel directory plus some extra sprinkles of things)
* Install firefox (can we just use iceweasel perhaps?)
* Install IDLE
* Figure out file syncing

Acknowledgements
----------------

* [This markdown cheatsheet][md_guide] was very useful in designing this README
* [Kali][kali] was invaluable to recover these files when a misstep caused the system to delete all the users and home directories, taking the initial (already well underway) version of this README with it. Needless to say, git was used immediately after that.
* [Past me][arch601] was invaluable as a stepping stone, although I must say he should have done more docs.

[wireless]: http://ubuntuforums.org/showthread.php?t=1238387 "[SOLVED] Using /etc/network/interfaces to Connect with Two Different Networks"
[pam_unsuccessful_login]: http://unix.stackexchange.com/questions/87225/pam-action-on-unsuccessful-login "pam: action on (unsuccessful) login"
[pam_guide]: http://aplawrence.com/Basics/understandingpam.html "Understanding PAM Authentication and Security"
[pam_exec_man]: http://linux.die.net/man/8/pam_exec "pam_exec(8) - Linux Man Page"
[md_guide]: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Markdown Cheatsheet"
[kali]: https://www.kali.org/ "Kali Linux"
[arch601]: https://github.com/Cynary/distro6.01/ "6.01 Arch Distribution"
[debiantrack]: https://wiki.debian.org/InstallingDebianOn/Thinkpad/Trackpoint "InstallingDebianOn/Thinkpad/Trackpoint"
[debiantap]: https://wiki.debian.org/SynapticsTouchpad#System-wide_configuration "SynapticsTouchpad"
[keybind]: http://askubuntu.com/questions/370304/xf86-keybinds-in-openbox "keyboard - XF86 keybinds in Openbox"
[oripage]: http://ori.scs.stanford.edu/ "Ori File System"
[oridl]: https://bitbucket.org/orifs/ori/downloads/ori-0.8.1.tar.xz "Ori Source"
[oriinstall]: https://bitbucket.org/orifs/ori/overview "orifs / ori - Bitbucket"
[oripaper]: http://sigops.org/sosp/sosp13/papers/p151-mashtizadeh.pdf "Replication, History, and Grafting in the Ori File System"
[encfssetup]: https://www.howtoforge.com/encrypting_encfs_pam_script "Creating a safe directory with PAM and EncFS"
[grubbg]: http://www.howtogeek.com/196655/how-to-configure-the-grub2-boot-loaders-settings/ "How to configure the GRUB2 Boot Loader's Settings"
