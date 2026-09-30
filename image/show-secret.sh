#!/bin/bash

echo 'Content-Type: text/html'
echo ''

# Points at the Python (pynter-ev3) device identity, not Source - Source's own pipeline
# (sinter_host, /var/lib/sling) keeps running unchanged in the background, it's just not exposed
# through pairing right now while Python support is what's being brought up. Repoint back to
# /var/lib/sling/secret_b62 once Source pairing is picked back up.
SECRET=$(cat /var/lib/sling-python/secret_b62 || echo 'Unable to read secret')
PLAYGROUND_URL='https://sourceacademy.nus.edu.sg/playground?add_device='

if [ "$(cat .enable)" == '0' ]; then
    echo "Not Authorized."
else
    echo '<!DOCTYPE html><html lang="en"><head><title>EV3 Device Panel</title><meta name="color-scheme" content="dark"><style>:root{font-family:sans-serif;text-align:center}input{flex-grow:1}body{background-color:#182530}p{display:flex}div{margin-inline:auto;max-width:max(50%,720px);background-color:#2c3d50;padding:16px;border:1px solid #556471}</style></head><body><h1>EV3 Device Panel (Python)</h1><div><p>Your device secret is:&nbsp;<input readonly="readonly" value='"'$SECRET'"'></p><a href="'"$PLAYGROUND_URL"''"$SECRET"'" target="_blank"><img src="/cgi-bin/qr.cgi" alt="QR code not available. Please click this link instead."></a><p>Click the QR code above to register the EV3 with your account (you must be logged in into Source Academy).</p></div></body></html>'
fi
