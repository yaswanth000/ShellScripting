#!/usr/bin/bash
set +x

# Start time of the script
start_time=$(date +%s)

function calcs3foldersize() {
    bucket="$1"
    folder="$2"

    # Calculate total size of all objects under the folder in bytes
    sizeInBytes=$(aws s3 ls "s3://${bucket}/${folder}" --recursive --summarize | awk '/Total Size/{print $3}')

    # Convert bytes to megabytes
    sizeInMB=$(echo "scale=2; $sizeInBytes / (1024 * 1024)" | bc)

    # Print Bucket, Folder path, and Total Size in MB
    if [ -n "${sizeInMB}" ]; then
        printf "%s,%s,%.2f MB\n" "${bucket}" "${folder}" "${sizeInMB}"
    else
        printf "%s,%s,0 MB\n" "${bucket}" "${folder}"
    fi
}

# Specify the bucket name
bucket_name="med-av-daas-preprod-datasci-cicd"

# CSV file path
csv_file="allregions-folders-s3-sizes.csv"

# Remove existing CSV file if present
[ -f "$csv_file" ] && rm -f "$csv_file"

# Write header to CSV file
echo "Bucket,Folder,Total Size (MB)" >> "$csv_file"

# List all folders (prefixes that end with '/') in the bucket
aws s3 ls "s3://${bucket_name}/" | grep " PRE " | awk '{print $2}' |
while read -r folder; do
    # Call function to calculate folder size and append to CSV file
    calcs3foldersize "${bucket_name}" "${folder}" >> "$csv_file"
done

# End time of the script
end_time=$(date +%s)
# Calculate runtime in seconds
runtime=$((end_time - start_time))

# Email the CSV file
echo "Please find attached the CSV file." | mailx -s "S3 Folder Sizes Report (Runtime: ${runtime} seconds)" -a "$csv_file" ramakanth.nerandla@ge.com

echo "CSV file '$csv_file' sent via email."
echo "Total runtime of the script: ${runtime} seconds."
