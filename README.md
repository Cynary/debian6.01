Debian for 6.01
===============

Software distribution for setting up Debian Stable (8.3.0 Jessie) on the 6.01 class laptops.

Installing
----------

Installing is simple. You simply have to run the install.sh script as root:

```bash
chmod +x install.sh
sudo ./install.sh
```

Overview
--------

Here's a simple overview of what `install.sh` does:

1. Install useful packages
  * *emacs-nox*
  * *tmux*
  * *build-essential*

   Not necessarily used by the students, but potentially useful for staff

2. Install necessary packages
  * *firmware-iwlwifi*
  * *dhcpcd5*

     These packages are networking magic. The firmware has the necessary drivers, dhcpcd will
     aggressively try to reconnect to any network on any interface.

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


The Magic
---------

### Network

The dhcpcd service agressively tries to renew connections. It won't, however, start if the interfaces in /etc/network/interfaces are setup to
use a dhcp client already. This file simply adds the wireless network interface (this causes it to start on system startup, and try to connect
to a specific SSID) and undoes all the damage done by the dhcp parameter every tutorial mindlessly adds at the end.

Note: if needed, one can configure the wireless to use multiple networks, some using even WPA, via wpa_supplicant. This is done by creating a
configuration file, and inserting the networks there. It was not done for the current release, as the MIT network is probably the most reliable
one for us. If so desired, an example of this can be found at [this ubuntu forums thread][wireless].

### Kerberos login/tickets

The *krb5.conf* simply adds a `forwardable = true` line to the file, so that you can forward tickets, and more easily login to dialup.

**WORK IN PROGRESS** we might use the tickets when we have a new file synchronization mechanism. We might also do it automatically (a la firefox
certificate stealing).

[wireless]: http://ubuntuforums.org/showthread.php?t=1238387 "[SOLVED] Using /etc/network/interfaces to Connect with Two Different Networks"