echo "Enter your contact email for the SSL certificates:"
read EMAIL

docker network create -d overlay --attachable proxy

docker run --detach \
    --name nginx-proxy \
    --network proxy \
    --publish 80:80 \
    --publish 443:443 \
    --volume $PWD/max_body_size.conf:/etc/nginx/conf.d/max_body_size.conf:ro \
    --volume /etc/nginx/certs \
    --volume /etc/nginx/vhost.d \
    --volume /usr/share/nginx/html \
    --volume /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy

docker run --detach \
    --name nginx-proxy-letsencrypt \
    --volumes-from nginx-proxy \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --env "DEFAULT_EMAIL=$EMAIL" \
    jrcs/letsencrypt-nginx-proxy-companion
