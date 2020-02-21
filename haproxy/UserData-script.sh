#!/bin/bash -ex
# This script will prepare the ubuntu vanilla instance
# Install HAproxy
apt-get update 
apt-get install -y haproxy unzip
# Install AWS CLI
curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
# Download the autoscaling group register script and template
cd /etc/haproxy/
wget https://raw.githubusercontent.com/montanor/marfeel-tech-test/master/haproxy/auto-add-instances.sh
wget -O haproxy.cfg.template https://raw.githubusercontent.com/montanor/marfeel-tech-test/master/haproxy/haproxy.cfg
chmod +x auto-add-instances.sh
echo "*/3 * * * * /etc/haproxy/auto-add-instances.sh > /etc/haproxy/auto-add-log" | tee -a /var/spool/cron/crontabs/root