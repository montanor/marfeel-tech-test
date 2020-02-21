#!/bin/bash -ex

# The following commented lines where used to setup the vanilla ubuntu image          
# Install Python and Nginx
# apt-get update
# apt-get install -y python3 nginx

# Create Nginx Cache folder
mkdir -p /tmp/nginx/cache
# Autostart Nginx and web app
systemctl enable nginx
systemctl enable webapp
# Clone the Python app source code
cd /opt
git clone https://bitbucket.org/Marfeel/appserverpythontestapp.git
mv appserverpythontestapp/ test/
# Start the Python App in background (The AMI already has this as a service)
systemctl start nginx
systemctl start webapp
#cd /opt/test
#/usr/bin/python3 -m http.server --cgi 8080 &> /dev/null &