#!/bin/bash

if [ "$(cat .enable)" == '0' ]; then
    echo 'Content-Type: text/html'
    echo ''
    echo "Not Authorized."
else
    echo -en 'Content-Type: image/png\n\n'
    # Python (pynter-ev3) device identity - see show-secret.sh's comment
    cat /var/lib/sling-python/secret_image.png || echo ''
    echo ''
fi
