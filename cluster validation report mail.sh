#!/bin/bash
#set -vx
U1=`whoami`
Date=`date +"%d%m%y_%H%M%S"`
ScrDir=`pwd`
mail="aviation_dba_x1_alerts@ge.com"
TAG_NAME="2fa_access_group"
INSTANCE_ID="`wget -qO- http://instance-data/latest/meta-data/instance-id`"
REGION="`wget -qO- http://instance-data/latest/meta-data/placement/availability-zone | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
TAG_VALUE="`aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region $REGION --output=text | cut -f5`"
echo $TAG_VALUE

nixGroup=(DATASCI RDF CT7 LDP)

 for val in "${nixGroup[@]}";
  do
   value=$(echo $val | cut -d '_' -f 1)
   if  $(echo "$TAG_VALUE" | grep -q -e $value) ; then
        echo $value
        if [ $value = "LDP" ]; then
           env=$(echo $TAG_VALUE | cut -d '_' -f 5)
           if [ $env = "NONPROD" ]; then
              env="preprod"
           else
              env="prod"
           fi
        else
        env=$(echo $TAG_VALUE | cut -d '_' -f 7 | cut -d ':' -f 1)
        env=$(echo $env | xargs echo -n)
        if [ $env = "NP" ]; then
        env="preprod"
        else
        env="prod"
        fi
        fi
        name=$(echo $val | cut -d '_' -f 1)
        nameU=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        bucket="med-av-daas-"$env-$nameU
        echo $bucket
        echo success
   fi
 done

Bucket=s3://$bucket
echo $Bucket
echo -e " EMR: Cluster Validation Report at" `date` >> /tmp/Check_list$Date.log
echo -e "==============================================================" >> /tmp/Check_list$Date.log
export JAVA_HOME=/etc/alternatives/jre
sh /home/hadoop/cluster_check_list.sh >> /tmp/Check_list$Date.log 2>&1
echo -e "Please find the Attached Cluster Validation Report\n" > /tmp/List
echo -e "\nBelow are the List of Checks:" >> /tmp/List
echo -e "\nHDFS : Create and Load Data into HDFS and S3" >> /tmp/List
echo -e "\nHIVE : Create and Load Data into Tables pointing to HDFS and S3 from Hive" >> /tmp/List
echo -e "\nSPARK : Create and Load Data from Spark" >> /tmp/List
echo -e "\nPYTHON : Comparing package versions and Importing the packages" >> /tmp/List
echo -e "\n\nThank You" >> /tmp/List
echo -e "\nPlatform Team" >> /tmp/List

#cat /tmp/List| mailx -s "EMR: Cluster Validation Report on $name $env `hostname -i`" -a /tmp/Check_list$Date.log $mail
cat /tmp/List| mailx -s "EMR: Cluster Validation Report on $name $env `hostname -i`" -a /tmp/Check_list$Date.log -a /tmp/python_checklist.log $mail
