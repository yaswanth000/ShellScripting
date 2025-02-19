#!/bin/bash

# Step 1: Run df -h to list all mounts, include / and /emr using regex, and filter out unwanted ones
mount_points=$(df -h | awk '{if ($6 ~ /^\/mnt/ || $6 == "/" || $6 == "/emr") print $6}' | grep -vE "^/mnt/(boot|tmp|data-backup|run|sys)")

# Step 2: Start creating the new JSON configuration with dynamic mount points
cat > config_bkp.json <<EOL
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "metrics": {
        "aggregation_dimensions": [
            [
                "InstanceId"
            ]
        ],
        "append_dimensions": {
            "AutoScalingGroupName": "\${aws:AutoScalingGroupName}",
            "ImageId": "\${aws:ImageId}",
            "InstanceId": "\${aws:InstanceId}",
            "InstanceType": "\${aws:InstanceType}"
        },
        "metrics_collected": {
            "collectd": {
                "metrics_aggregation_interval": 60
            },
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
EOL

# Step 3: Add dynamically determined mount points to the resources array
for mount in $mount_points; do
    echo "                   \"$mount\"," >> config_bkp.json
done

# Step 4: Remove the last comma to make the JSON valid
sed -i '$ s/,$//' config_bkp.json

# Step 5: Add the rest of the JSON configuration
cat >> config_bkp.json <<EOL
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            },
            "statsd": {
                "metrics_aggregation_interval": 60,
                "metrics_collection_interval": 60,
                "service_address": ":8125"
            }
        }
    }
}
EOL

echo "CloudWatch Agent configuration with dynamic mount points has been generated: config_bkp.json"