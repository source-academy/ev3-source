#!/bin/bash

set -euxo pipefail

SCRIPT_PATH="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# allow passwordless sudo for robot
echo "robot ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/robot

# stop sudo from doing a DNS lookup -- ensures executables can be run when network is down
echo -e "Defaults\t!fqdn" >> /etc/sudoers

# install sling.service (Source, prod) / sling-stg.service (Source, stg), sling-python.service
# (Python, prod) / sling-python-stg.service (Python, stg), set permissions - see start-sling.sh's
# own comment for why prod and stg each get their own persistent service instead of one script
# picking a backend
mv /usr/local/bin/sling.service /usr/local/bin/sling-stg.service /usr/local/bin/sling-python.service /usr/local/bin/sling-python-stg.service /usr/local/bin/panel.service /etc/systemd/system/
chmod 644 /etc/systemd/system/sling.service /etc/systemd/system/sling-stg.service /etc/systemd/system/sling-python.service /etc/systemd/system/sling-python-stg.service /etc/systemd/system/panel.service
systemctl enable sling.service sling-stg.service sling-python.service sling-python-stg.service panel.service

# set permissions to our executables
chmod 755 /usr/local/bin/uuidtob62
chmod 755 /usr/local/bin/sling /usr/local/bin/sinter_host /usr/local/bin/start-sling.sh
chmod 755 /usr/local/bin/pynter-ev3 /usr/local/bin/start-sling-python.sh

# disable systemd-resolved
systemctl disable systemd-resolved.service

# add sling data directories - kept fully separate (own secret/device identity each) so Source's
# existing pipeline is untouched by the Python one sitting alongside it
mkdir -p /var/lib/sling /var/lib/sling-python
chmod 755 /var/lib/sling /var/lib/sling-python
chown robot:robot /var/lib/sling /var/lib/sling-python

# install uuidgen
cd /dev/shm
curl -LO http://archive.debian.org/debian/pool/main/u/util-linux/uuid-runtime_2.29.2-1+deb9u1_armel.deb
curl -LO http://archive.debian.org/debian/pool/main/b/busybox/busybox-static_1.22.0-19+b3_armel.deb
dpkg -i uuid-runtime_2.29.2-1+deb9u1_armel.deb
dpkg -i busybox-static_1.22.0-19+b3_armel.deb
systemctl disable uuidd.socket
rm uuid-runtime_2.29.2-1+deb9u1_armel.deb busybox-static_1.22.0-19+b3_armel.deb

# Set up first-boot items:
# - Install RTL8811CU drivers
# - Disable SSH
# - Disable Webserver
# - Reset to a random login password
# - Reboot
sed -e '/^\s*;;$/{i \
        depmod\
        systemctl disable ssh\
        echo 0 > /srv/www/cgi-bin/.enable\
        NEWPASS=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 6)\
        echo "$NEWPASS\n$NEWPASS" | passwd robot\
        reboot' \
    -e ':a;n;ba}' -i /etc/init.d/firstboot

# Boot-reliability fixes found while testing on real hardware - see source-academy/ev3-source#21
# for the full writeup of each one.

# /dev/mmcblk0p1 (the boot/flash partition) is sometimes slow enough to enumerate on real MMC
# hardware that the default systemd device-wait exceeds its timeout, which without `nofail`
# drops the whole boot into emergency mode - even though the partition has already been read
# once already, successfully, by the bootloader itself before systemd ever starts. `nofail` +
# a shorter device timeout means a slow-to-appear card no longer blocks boot; a genuinely
# missing partition would still fail the mount, just without holding up everything else.
sed -i 's|\(/dev/mmcblk0p1 *\/boot/flash *vfat *defaults,errors=remount-ro,noatime\) *0 *2|\1,nofail,x-systemd.device-timeout=10 0 2|' /etc/fstab

# connman-wait-online.service blocks network-online.target until an actual WiFi connection
# exists - which can never happen on first boot, before any network is configured, creating a
# hard deadlock. sling.service/sling-python.service already retry on their own
# (Restart=always), so nothing actually needs to block boot on this.
rm -f /etc/systemd/system/network-online.target.wants/connman-wait-online.service

# ev3-usb@.service / lms2012-compat-usb-hid-gadget@.service (USB gadget mode for LEGO's own
# official software, over a direct USB cable) both hard-depend (BindsTo=) on the UDC device
# unit appearing, which is unreliable on this board and was blocking boot even though nothing
# in this image otherwise needs it. Masked rather than left to time out.
ln -sf /dev/null /etc/systemd/system/ev3-usb@.service
ln -sf /dev/null /etc/systemd/system/lms2012-compat-usb-hid-gadget@.service

# The two udev rules for this device still tag it TAG+="systemd" even with the services above
# masked, which makes systemd track the device as its own unit with the same unreliable boot
# timeout, independent of any specific service wanting it. Replaced with untagged versions
# (see image/udev-rules.d/) - device alias (/sys/subsystem/udc/devices/$kernel) still gets
# created either way, systemd just never waits on it.
cp /usr/local/share/ev3-source-udev-rules/60-ev3.rules /lib/udev/rules.d/60-ev3.rules
cp /usr/local/share/ev3-source-udev-rules/60-lms2012-compat-usb-hid-gadget.rules /lib/udev/rules.d/60-lms2012-compat-usb-hid-gadget.rules
rm -rf /usr/local/share/ev3-source-udev-rules

# make journald log to memory only
cat <<EOF > /etc/systemd/journald.conf
[Journal]
Storage=volatile
RuntimeMaxUse=4M
EOF

# make cgi-bin
mkdir -p /srv/www/cgi-bin
mv /usr/local/bin/show-secret.sh /srv/www/cgi-bin/index.cgi
mv /usr/local/bin/show-qr.sh /srv/www/cgi-bin/qr.cgi
chmod 755 /srv/www/cgi-bin/index.cgi
chmod 755 /srv/www/cgi-bin/qr.cgi

# delete ourselves
rm -f "$SCRIPT_PATH"
