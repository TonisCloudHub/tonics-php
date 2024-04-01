#!/bin/bash

# Init incus
sudo incus admin init --auto

# Launch Instance
sudo incus launch images:debian/bookworm/amd64 tonics-php

# Dependencies
sudo incus exec tonics-php -- bash -c "apt update -y && apt upgrade -y"

sudo incus exec tonics-php -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y php php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-readline php8.2-gd  php8.2-gmp php8.2-bcmath  php8.2-zip php8.2-curl php8.2-intl php8.2-apcu"

# Clean Debian Cache
sudo incus exec tonics-php -- bash -c "apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*"

# Version
Version=$(sudo incus exec tonics-php -- php -v | head -n 1 | awk '{print $2}' | cut -d '-' -f 1)

# Publish Image
mkdir images && sudo incus stop tonics-php && sudo incus publish tonics-php --alias tonics-php

# Export Image
sudo incus start tonics-php
sudo incus image export tonics-php images/php-bookworm-$Version

# Image Info
sudo incus image info tonics-php >> images/info.txt
