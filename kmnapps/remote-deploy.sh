#!/bin/bash
# kmnapps.xyz deploy - fetched and run from the VPS console as root.
# Usage (paste into console):
#   bash <(curl -sL https://raw.githubusercontent.com/mymyanmarland/vps-deploy/main/kmnapps/remote-deploy.sh)
set -e
BASE="https://raw.githubusercontent.com/mymyanmarland/vps-deploy/main/kmnapps"

echo "== installing nginx + certbot =="
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nginx python3-certbot-nginx dnsutils curl > /dev/null

echo "== downloading site files =="
curl -sL "$BASE/nginx-kmnapps.xyz" -o /etc/nginx/sites-available/kmnapps.xyz
ln -sf /etc/nginx/sites-available/kmnapps.xyz /etc/nginx/sites-enabled/kmnapps.xyz
mkdir -p /var/www/kmnapps.xyz
curl -sL "$BASE/www/index.html" -o /var/www/kmnapps.xyz/index.html

nginx -t && systemctl reload nginx
echo "== HTTP is up =="

SRV_IP=$(curl -s --max-time 10 https://api.ipify.org || hostname -I | awk '{print $1}')
DNS_IP=$(dig +short kmnapps.xyz @8.8.8.8 | head -1)
echo "server IP: $SRV_IP | DNS says: ${DNS_IP:-<not resolving yet>}"
if [ -n "$DNS_IP" ] && [ "$DNS_IP" = "$SRV_IP" ]; then
  echo "== DNS OK - issuing SSL certificates =="
  certbot --nginx --non-interactive --agree-tos --register-unsafely-without-email \
    -d kmnapps.xyz -d www.kmnapps.xyz \
    -d money.kmnapps.xyz -d ppt.kmnapps.xyz -d diabetes.kmnapps.xyz \
    -d svg.kmnapps.xyz -d perfume.kmnapps.xyz -d cafe.kmnapps.xyz \
    -d weather.kmnapps.xyz -d baydin.kmnapps.xyz -d image.kmnapps.xyz \
    -d pvz.kmnapps.xyz -d baby.kmnapps.xyz -d stories.kmnapps.xyz \
    -d monitor.kmnapps.xyz --redirect
  echo "== DONE: https://kmnapps.xyz =="
else
  echo "!! DNS not propagated yet. Wait ~30 min, then paste this for SSL:"
  echo 'bash <(curl -sL https://raw.githubusercontent.com/mymyanmarland/vps-deploy/main/kmnapps/remote-deploy.sh)'
fi
