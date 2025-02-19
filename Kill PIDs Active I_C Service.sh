#!/bin/bash
 
# Service name
SERVICE="instance-controller.service"
# Email details
EMAIL="yaswanth889@gmail.com"
SUBJECT="Instance Controller Service Status Update"
BODY="The following processes were killed due to high CPU/Memory usage and the instance-controller.service was restarted.\n\n"
BODY_PROCESS_KILLED=""
 
# Function to check service status
check_service() {
    if systemctl is-active $SERVICE >/dev/null 2>&1; then
        echo "$SERVICE is running."
        return 0
    else
        echo "$SERVICE is not running."
        return 1
    fi
}
 
# Initial check
check_service
 
# If service is not running, wait 2 minutes and check again
if [ $? -ne 0 ]; then
    echo "Checking again in 2 minutes..."
    sleep 120
 
    # Recheck service after 2 minutes
    check_service
 
    # If service is still not running, check for high CPU/Memory consuming processes
    if [ $? -ne 0 ]; then
        echo "$SERVICE is still not running after 2 minutes."
        
        # Find processes consuming high CPU or Memory
        echo "Searching for high memory and CPU consuming processes..."
 
        # List top 5 processes by memory usage
        high_mem_processes=$(ps aux --sort=-%mem | head -n 6)
        echo "High memory consuming processes:"
        echo "$high_mem_processes"
 
        # List top 5 processes by CPU usage
        high_cpu_processes=$(ps aux --sort=-%cpu | head -n 6)
        echo "High CPU consuming processes:"
        echo "$high_cpu_processes"
 
        # Get process IDs of top CPU/memory consuming processes
        high_mem_pids=$(echo "$high_mem_processes" | awk 'NR>1 {print $2}')
        high_cpu_pids=$(echo "$high_cpu_processes" | awk 'NR>1 {print $2}')
 
        # Combine the lists of process IDs to kill
        all_pids=$(echo "$high_mem_pids $high_cpu_pids" | tr ' ' '\n' | sort -u)
 
        # Prepare the list of killed processes
        BODY_PROCESS_KILLED="The following processes were killed:\n"
        for pid in $all_pids; do
            if [ -n "$pid" ]; then
                BODY_PROCESS_KILLED="$BODY_PROCESS_KILLED\nProcess $pid"
                echo "Killing process $pid"
                kill -9 $pid
            fi
        done
 
        # Restart the service after killing processes
        echo "Restarting $SERVICE..."
        systemctl restart $SERVICE
        echo "$SERVICE has been restarted."
 
        BODY="$BODY$BODY_PROCESS_KILLED\n$SERVICE has been restarted."
 
        # Send email
        echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL"
        echo "Email sent to $EMAIL."
    fi
fi