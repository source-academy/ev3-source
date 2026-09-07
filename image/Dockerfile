FROM ev3dev/ev3dev-stretch-ev3-base
# Copy our own binaries
COPY executables/uuidtob62 sling sinter_host pynter-ev3 /usr/local/bin/

# Copy WiFi drivers
COPY rtl8812cu-driver/8821cu.conf /etc/modprobe.d/
COPY rtl8812cu-driver/8821cu.ko /lib/modules/4.14.117-ev3dev-2.3.5-ev3/drivers/net/wireless/

# Copy configurations and run setup
# start-sling-python.sh/sling-python.service run pynter-ev3 (Python) as a second, independent sling
# instance alongside the existing Source one - own SLING_DIR, own device secret/identity - see
# start-sling-python.sh's own comment for why this is kept fully separate rather than touching the
# Source path at all.
COPY bootstrap.sh start-sling.sh sling.service start-sling-python.sh sling-python.service panel.service show-secret.sh show-qr.sh /usr/local/bin/
RUN ["bash", "-c", "chmod 755 /usr/local/bin/bootstrap.sh && exec /usr/local/bin/bootstrap.sh"]

# Copy QR code generator
ARG show_qrcode="Show QR Code"
COPY executables/${show_qrcode} /home/robot/
RUN ["bash", "-c", "chmod 755 \"/home/robot/${show_qrcode}\""]

# Copy control panel
ARG service_control="Source Academy Settings"
COPY executables/${service_control} /home/robot/
RUN ["bash", "-c", "chmod 755 \"/home/robot/${service_control}\""]

# Add script to kill a running Source Program
ARG kill_source="Kill Source Program"
COPY executables/${kill_source} /home/robot/
RUN ["bash", "-c", "chmod 755 \"/home/robot/${kill_source}\""]