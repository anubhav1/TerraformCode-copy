#!/bin/bash
su - ubuntu
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install nginx
sudo ufw allow 'Nginx Full'
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash
sudo apt-get install -y nodejs
sudo npm install ghost-cli@latest -g
sudo mkdir -p /var/www/myghost
sudo chown ubuntu:ubuntu /var/www/myghost
sudo chmod 775 /var/www/myghost
cd /var/www/myghost
sudo -u ubuntu ghost install \
        --url      "http://t3.pada.tk" \
        --db "mysql" \
        --dbhost "database-ghost.cypxadvwmyke.eu-central-1.rds.amazonaws.com" \
        --dbuser "ghostadmin" \
        --dbpass "ghostadmin" \
        --dbname "ghost_database" \
        --process systemd \
        --no-prompt 