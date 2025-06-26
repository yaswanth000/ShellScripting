#!/bin/bash

hostip=$(hostname -f)
instanceid=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
ip=$(hostname -i)
az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)
vpc=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$( ip address show dev eth0 | grep ether | awk ' { print $2  } ' )/vpc-id)
accountid=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep -oP '"accountId"\s*:\s*"\K[^"]+')

echo "host = $hostip:$instanceid:$ip:$az:$vpc:$accountid" > inp.conf

Inputs = $cat inp.conf
inputs = $cat inpbkp.conf

# inputs = echo $(cat /opt/splunkforwarder/etc/system/local/inputs.conf)

#host = ip-10-158-97.147.ec2.internal:i-0d509a4baa79fcf7a:10.158.97.147:us-east-1a:vpc-032ae02c66d84d881:254227609986

if [ "$Inputs" == "$inputs" ];
then
  echo ("splunk inputs.conf file matched")
else
  echo ("Not matched Editing splunk inputs.conf file")
#   vi /opt/splunkforwarder/etc/system/local/inputs.conf
#   cp "$Inputs" "$inputs"
fi
  

  