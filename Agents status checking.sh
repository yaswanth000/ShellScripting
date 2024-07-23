#!/bin/bash

# Check if Splunk agent is running
splunk_running=$(ps aux | grep -v grep | grep splunkd)
if [ -z "$splunk_running" ]; then
    echo "Splunk agent is not running."
else
    echo "Splunk agent is running."
fi

# Check if Qualys agent is running
qualys_running=$(ps aux | grep -v grep | grep qualys)
if [ -z "$qualys_running" ]; then
    echo "Qualys agent is not running."
else
    echo "Qualys agent is running."
fi

# Check if Falcon agent is running
falcon_running=$(ps aux | grep -v grep | grep falcon)
if [ -z "$falcon_running" ]; then
    echo "Falcon agent is not running."
else
    echo "Falcon agent is running."
fi