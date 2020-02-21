#!/bin/bash -ex

# Create Nginx Cache folder
mkdir -p /tmp/nginx/cache

# Autostart services
systemctl enable nginx
systemctl enable webapp

# Clone the Python app source code
cd /opt
git clone https://bitbucket.org/Marfeel/appserverpythontestapp.git
mv appserverpythontestapp/ test/

# Start the services
systemctl start nginx
systemctl start webapp
