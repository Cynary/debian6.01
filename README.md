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
5. Enable *dhcpcd*

   The *dhcpcd* service aggressively tries to get DHCP information from every interface. This is what allows the network to reliably stay on in these laptops.

6. Set python as a global *alias* for *python3*. That way, when a student types `python` in the terminal, they will get the `python3` terminal.

   **WORK IN PROGRESS** Debian Stable still has python3 as default, need to check if this will interfere in any way with lib601.

7. Copy files to their positions

   Via the application of a lot of magic (next section explains that magic in some detail) we have a small list of files that need to be modifed
   in a default Debian Jessie system. This step just puts those files in their respective positions (the structure is replicated in this repo).
   This step also sets the correct permissions.


The Magic
---------

### Network

The firmware is stored in a file, and that way we avoid having to add non-free repos to download it.

The dhcpcd service agressively tries to renew connections. It won't, however, start if the interfaces in /etc/network/interfaces are setup to
use a dhcp client already. This file simply adds the wireless network interface (this causes it to start on system startup, and try to connect
to a specific SSID) and undoes all the damage done by the dhcp parameter every tutorial mindlessly adds at the end (we instead just add manual).

Note: if needed, one can configure the wireless to use multiple networks, some using even WPA, via wpa_supplicant. This is done by creating a
configuration file, and inserting the networks there. It was not done for the current release, as the MIT network is probably the most reliable
one for us. If so desired, an example of this can be found at [this ubuntu forums thread][wireless].

### Kerberos login/tickets

The *krb5.conf* simply adds a `forwardable = true` line to the file, so that you can forward tickets, and more easily login to dialup.

**WORK IN PROGRESS** we might use the tickets when we have a new file synchronization mechanism. We might also do it automatically (a la firefox
certificate stealing, look [here][arch601 for that example).

To also get Kerberos login to work, we had to modify the PAM files. The part that allowed the login to actually happen was mostly there, but it only worked if there was already a user. If that were not true, the login would fail. Modifications from a [previous project][arch601] were used, although they were and will remain largely undocumented. To better control what users get created and make sure no extra users were left on the system, we did some modifications based on the information [here][pam_unsuccessful_login], [here][pam_guide], and [here][pam_exec_man].

**BE VERY CAREFUL MAKING CHANGES LIKE THIS**. A small mistake during development caused the system to delete every user in the system along with every home directory. The original draft for this project lived in that original system. The files were all recovered thanks to file recovery programs but it was an unpleasant experience.

The current login flow looks like:
If local login fails, but kerberos login succeeds create a new user, along with a home directory for the user. (createUser and pam_mkhomedir do this). There is also a fix done to their kerberos tickets so that this new user can use them (fixKRBTickets does this).
When a logout happens, as long as it's not one of the specified system users (root, alpha, or beta), then the user gets deleted along with all their files. (this is done in cleanUser).

Acknowledgements
----------------

* [This markdown cheatsheet][md_guide] was very useful in designing this README
* [Kali][kali] was invaluable to recover these files when a misstep caused the system to delete all the users and home directories, taking the initial (already well underway) version of this README with it. Needless to say, git was used immediately after that.

[wireless]: http://ubuntuforums.org/showthread.php?t=1238387 "[SOLVED] Using /etc/network/interfaces to Connect with Two Different Networks"
[pam_unsuccessful_login]: http://unix.stackexchange.com/questions/87225/pam-action-on-unsuccessful-login "pam: action on (unsuccessful) login"
[pam_guide]: http://aplawrence.com/Basics/understandingpam.html "Understanding PAM Authentication and Security"
[pam_exec_man]: http://linux.die.net/man/8/pam_exec "pam_exec(8) - Linux Man Page"
[md_guide]: https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Markdown Cheatsheet"
[kali]: https://www.kali.org/ "Kali Linux"
[arch601]: https://github.com/Cynary/distro6.01/ "6.01 Arch Distribution"
