# post-invoke

This is a script that will alert you when a server restart OR service restart is required.

# Setup Instructions

* Set up unattended-upgrades
* Set up a DPkg `post-invoke` script
* Run this script sometime afterwards (via cron?)

## `unattended-upgrades`

See guides on [How to setup unattended-upgrades](https://linuxiac.com/how-to-set-up-automatic-updates-on-debian/).

## post-invoke script

I'm running `checkrestart` as a `post-invoke` script. `checkrestart` can be installed via `debian-goodies`.

```
# apt-get install debian-goodies
# cat << EOF >/etc/dpkg/dpkg.cfg.d/999checkrestart
post-invoke "/usr/sbin/checkrestart > /var/run/check-restart-output 2>&1"
EOF
```

## Run this script afterwards

**Process to be determined**

I suggest you run this out of sync with `unattended-upgrades` until I figure out a more efficient way to do this. Otherwise, you'll be getting more alerts than you know what to do with.

# Background

DPkg is invoked on Debian and Debian derivatives after something is installed or configured (among other things).

I've decided to run checkrestart, a script that checks to see if any services need to be restarted to take advantage of updated libraries, etc.

This will undoubtedly be run more than once every time unattended upgrades runs successfully.

