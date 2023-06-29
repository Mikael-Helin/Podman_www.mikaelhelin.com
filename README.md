# Podman www.mikaelhelin.com

## Creating an Nginx image

We are not to use the official Nginx image, instead we will build our own Nginx image based on a Debian image

    su - production
    cd ~/www.mikaelhelin.com
    buildah bud -t localhost:5000/nginx/nginx__debian-bullseye:latest .
    podman run -dt --name=nginx-temp localhost:5000/nginx/nginx__debian-bullseye:latest
    nginx_version=$(podman exec nginx-temp nginx -v 2>&1 | cut -d '/' -f 2)
    podman stop nginx-temp
    podman rm nginx-temp
    echo $nginx_version

which we push into the registry

    podman login localhost:5000
    podman push localhost:5000/nginx/nginx__debian-bullseye:latest
    podman tag localhost:5000/nginx/nginx__debian-bullseye:latest localhost:5000/nginx/nginx__debian-bullseye:$nginx_version
    podman push localhost:5000/nginx/nginx__debian-bullseye:$nginx_version
    curl -u mikael http://localhost:5000/v2/nginx/nginx__debian-bullseye/tags/list

## Run the Nginx container

There are a few urls we need to CNAME at my domain registry, they are for example

* www.mikaelelin.com
* containers.mikaelhelin.com (here as localhost)
* git.mikaelhelin.com
* wiki.mikaelhelin.com

First chmod the script for www.mikaelhelin.com

    su - production
    cd ~/www.mikaelhelin.com
    chmod +x run_www.mikaelhelin.com.sh

and then insert a systemd file to run the script

    su -
    mv www.mikaelhelin.com.service /etc/systemd/system/www.mikaelhelin.com.service
    systemctl daemon-reload
    systemctl enable www.mikaelhelin.com.service
    reboot
