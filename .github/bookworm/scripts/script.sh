#!/bin/bash

# Init incus
sudo incus admin init --auto

PHP_VERSION=$1

# Launch Instance
sudo incus launch images:debian/bookworm/amd64 tonics-php

# Dependencies
sudo incus exec tonics-php -- bash -c "apt update -y && apt upgrade -y"

if (( $(echo "$PHP_VERSION > 8.2" | bc -l) )); then

  # Add Ondrej's repo source and signing key along with dependencies
  sudo incus exec tonics-php -- bash -c "apt install -y curl apt-transport-https lsb-release"
  sudo incus exec tonics-php -- bash -c  "curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg"
  sudo incus exec tonics-php -- bash  <<HEREDOC
  echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(sudo incus exec tonics-php -- lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
HEREDOC

  sudo incus exec tonics-php -- bash -c "apt update -y"

fi

sudo incus exec tonics-php -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y php$PHP_VERSION php$PHP_VERSION-fpm php$PHP_VERSION-{mysql,mbstring,readline,gd,gmp,bcmath,zip,curl,intl,apcu}"

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
