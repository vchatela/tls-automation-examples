# sudo apt update
# sudo apt install certbot python3-certbot-dns-cloudflare

sudo certbot certonly \
  --dns-cloudflare \
  --dns-cloudflare-credentials ~/cloudflare.ini \
  -d your.domain.com \
  --agree-tos \
  --no-eff-email \
  -m your@email.com
