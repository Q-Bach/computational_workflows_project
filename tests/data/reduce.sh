#!/bin/bash
# Script to extract the first 100 reads of the fastq files

# Number of lines to extract
n=400

# Check if the number of lines is provided
if [ -z "$n" ]; then
    echo "Usage: $0 <number_of_lines>"
    exit 1
fi

# Loop through all .gz files in the current directory
for file in *.gz; 
do
    # Extract the base name of the file
    base_name=$(basename "$file" .gz)
    
    # Extract the first n lines and compress them again
    zcat "$file" | head -n "$n" | gzip > "reduced_${base_name}.gz"
done