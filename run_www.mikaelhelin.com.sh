#!/bin/bash

if ! podman pod exists www.mikaelhelin.com; then 
    # Create data directories
    mkdir -p DATA/{etc__nginx,var__www__html}
    
    # Populate data directories
    echo "Hello World" > DATA/var__www__html/index.html
    chmod 755 -R DATA
    temp_container=$(podman run -d nginx/nginx__debian-bullseye)
    podman cp $temp_container:/etc/nginx/. ./DATA/etc__nginx
    podman rm -f $temp_container

    # Create pod
    podman pod create \
        --network production-ipv4-network \
        --network production-ipv6-network \
        www.mikaelhelin.com;
fi

if ! podman container exists www.mikaelhelin.com-nginx; then
    # Create container
    podman run \
        --name www.mikaelhelin.com-nginx --restart=always \
        --pod www.mikaelhelin.com \
        -v ./DATA/var__www__html:/var/www/html:Z \
        -v ./DATA/etc__nginx:/etc/nginx:Z \
        -d nginx/nginx__debian-bullseye
fi

while true; do
    if podman pod exists www.mikaelhelin.com && [ "$(podman pod inspect www.mikaelhelin.com --format "{{.State}}")" = "Running" ]; then
        sleep 300;
    else
        podman pod start www.mikaelhelin.com
        sleep 10;
    fi
done
