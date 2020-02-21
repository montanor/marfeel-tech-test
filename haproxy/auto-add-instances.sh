#!/bin/bash
# This script injects the private IP address of the instances launched by an AWS Autoscaling Group
# into the haproxy configuration file. You must authenticate the AWS CLI first or use an instance role.
# NOTE: The haproxy.cfg must be initialized with the following sample:
# https://raw.githubusercontent.com/montanor/marfeel-tech-test/master/haproxy/haproxy.cfg
# Author: David Montaño (20200220)
# CRON Expression: */3 * * * * /etc/haproxy/auto-add-instances.sh > /etc/haproxy/auto-add-log

# Backup haproxy.cfg
cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

# Reinitialize haproxy with the template
cp /etc/haproxy/haproxy.cfg.template /etc/haproxy/haproxy.cfg

# Get the id of the current instances launched by the ASG
instanceList=$(/usr/local/bin/aws autoscaling describe-auto-scaling-groups --output text | grep INSTANCES | awk '{print $4}')
#echo "${instanceList}"


# Iterate over the list of ids to get the private IP address
for id in $instanceList
do
    # Generate a random server id for haproxy (To assign the cookies)
    uuid=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)

    # Get the instance private address
    ipAddress=$(/usr/local/bin/aws ec2 describe-instances --instance-ids ${id} --query 'Reservations[].Instances[].PrivateIpAddress' --output text)

    # Create the line for the haproxy.cfg file and append to the end of haproxy.cfg
    echo "  server ${uuid} ${ipAddress}:80 cookie ${uuid}" >> /etc/haproxy/haproxy.cfg

done

# Check integrity of the new file
/usr/sbin/haproxy -c -V -f /etc/haproxy/haproxy.cfg

if [ $? -eq 0 ]; then
    echo "$(date) Configuration file is OK, reloading HAproxy"
    /usr/sbin/service haproxy reload
else
    echo "$(date) Autoconfiguration failed, reverting changes"
    cp /etc/haproxy/haproxy.cfg.bak /etc/haproxy/haproxy.cfg
fi


