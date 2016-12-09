#!/usr/bin/env bash

# Keep Ubuntu from trying to access 'stdin'
export DEBIAN_FRONTEND=noninteractive

# Variables
DBPASSWD=root
SERVERNAME=jkrusinski.dev

# Status message
echo "Provisioning virtual machine..."

# Bash Prompt
echo "--- Formatting bash prompt ---"
cat /var/www/.provision/config/bashrc.sh > /home/vagrant/.bashrc

# Update Packages
echo "--- Updating system packages ---"
apt-get -qq update

# Vim, Curl, Build-Essential, Software-Properties-Common, & Python-Software-Properties
echo "--- Installing base packages ---"
apt-get -y install vim curl build-essential software-properties-common python-software-properties > /dev/null 2>&1

# Git
echo "--- Installing Git ---"
apt-get install git -y > /dev/null 2>&1

# Nginx
echo "--- Installing Nginx ---"
apt-get install nginx -y > /dev/null 2>&1

# Add Repos
echo "--- Add Node.js and PHP5 repositories to update distribution ---"
add-apt-repository -y ppa:ondrej/php5 > /dev/null 2>&1
add-apt-repository -y ppa:chris-lea/node.js > /dev/null 2>&1

# Update Packages List
echo "--- Updating Packages List ---"
apt-get -qq update

# PHP
echo "--- Installing PHP ---"
apt-get -y install php5-common php5-dev php5-cli php5-fpm > /dev/null 2>&1
sed -n "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini

# PHP Extensions
echo "--- Installing PHP Extensions ---"
apt-get -y install php5-curl php5-gd php5-mcrypt php5-mysql > /dev/null 2>&1

# MySQL
echo "--- Installing MySQL ---"
apt-get -y install debconf-utils > /dev/null 2>&1
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server > /dev/null 2>&1

# Configure Nginx
echo "--- Configuring Nginx ---"
cp /var/www/.provision/config/nginx_server /etc/nginx/sites-available/${SERVERNAME}
cat /var/www/.provision/config/nginx_http > /etc/nginx/nginx.conf
cat /var/www/.provision/config/nginx_proxy_params > /etc/nginx/proxy_params
ln -s /etc/nginx/sites-available/${SERVERNAME} /etc/nginx/sites-enabled/
rm -rf /etc/nginx/sites-available/default
service nginx restart > /dev/null 2>&1

# Node.js & NPM - Fixes NPM Permissions
echo "--- Installing Node.js ---"
apt-get -y install nodejs > /dev/null 2>&1
sudo -u vagrant -H sh -c "mkdir /home/vagrant/.npm-global"
sudo -u vagrant -H sh -c "echo 'prefix=~/.npm-global' > /home/vagrant/.npmrc"
echo 'export PATH=~/.npm-global/bin:$PATH' >> /home/vagrant/.profile

# Composer
echo "--- Installing Composer ---"
curl --silent https://getcomposer.org/installer | php > /dev/null 2>&1
mv composer.phar /usr/local/bin/composer

# Supervisor
echo "--- Installing Supervisor ---"
npm install -g supervisor > /dev/null 2>&1

# MongoDB
echo "--- Installing MongoDB ---"
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927 > /dev/null 2>&1
echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list > /dev/null 2>&1
apt-get update > /dev/null 2>&1
apt-get install mongodb-org -y > /dev/null 2>&1
