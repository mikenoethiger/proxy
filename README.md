Installation
============

Use the `intall.sh` script to execute all steps described here.

Step 1: Create Proxy Network
----------------------------

Create the proxy network. (Required for the proxy to connect to swarm containers created via `docker-compose.yml`.) (`--attachable` is required to attach local containers to this network (such as the `nginx-proxy`)

```
docker network create -d overlay --attachable proxy
```

> **Notice:** Whenever you deploy a container with `docker stack deploy -c docker-compose.yml`, make sure to attach this container to the `proxy` network. 
> Otherwise, the `nginx-proxy` will not be able to connect to this container. By default, the `nginx-proxy` can only connect to local containers created with `docker run`.
> Alternatively, you can connect the `nginx-proxy` to your containers network `docker network connect other-network nginx-proxy`.

Step 2: Create the Proxy
------------------------

```
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
```

Step 3: Create the Letsencrypt Proxy Companion
----------------------------------------------

```
docker run --detach \
    --name nginx-proxy-letsencrypt \
    --volumes-from nginx-proxy \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --env "DEFAULT_EMAIL=your@email.com" \
    jrcs/letsencrypt-nginx-proxy-companion
```

Connect a Container to the Proxy
================================

Now whenever you start a new container, add the `VIRTUAL_HOST` and `LETSENCRYPT_HOST` environment variables with all the domains you want to have proxied. 

For example:

```
docker run -d \ 
    --env "VIRTUAL_HOST=domain.org,www.domain.org" \
    --env "LETSENCRYPT_HOST=domain.org,www.domain.org" \
    --expose 80 \
    image:latest
```

Links
=====

* [nginx-proxy](https://github.com/nginx-proxy/nginx-proxy)
* [Multiple Networks](https://github.com/nginx-proxy/nginx-proxy#multiple-networks)
* [Multiple Hosts](https://github.com/nginx-proxy/nginx-proxy#multiple-hosts)
* [Custom Configuration Proxy-wide](https://github.com/nginx-proxy/nginx-proxy#proxy-wide)
* [docker-letsencrypt-nginx-proxy-companion](https://github.com/nginx-proxy/docker-letsencrypt-nginx-proxy-companion)
