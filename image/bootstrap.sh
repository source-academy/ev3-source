#!/bin/bash

set -euxo pipefail

SCRIPT_PATH="$(realpath -s "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

# allow passwordless sudo for robot
echo "robot ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/robot

# stop sudo from doing a DNS lookup -- ensures executables can be run when network is down
echo -e "Defaults\t!fqdn" >> /etc/sudoers

# install sling.service (Source) and sling-python.service (Python), set permissions
mv /usr/local/bin/sling.service /usr/local/bin/sling-python.service /usr/local/bin/panel.service /etc/systemd/system/
chmod 644 /etc/systemd/system/sling.service /etc/systemd/system/sling-python.service /etc/systemd/system/panel.service
systemctl enable sling.service sling-python.service panel.service

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
