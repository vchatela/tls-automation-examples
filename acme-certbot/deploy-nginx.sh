docker run -d --name nginx-tls \
  -v /etc/letsencrypt/live/your.domain.com/fullchain.pem:/etc/nginx/cert.pem:ro \
  -v /etc/letsencrypt/live/your.domain.com/privkey.pem:/etc/nginx/key.pem:ro \
  -v $(pwd)/tls.conf:/etc/nginx/conf.d/default.conf:ro \
  -p 443:443 \
  nginx:alpine
