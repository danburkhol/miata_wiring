#!/bin/bash

# Path to this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Path to the output directory
OUTPUT_DIR="$SCRIPT_DIR/generated"

# Create the output directory if it doesn't exist
mkdir -p $OUTPUT_DIR

# Clean up the output directory except for any .svg files
find $OUTPUT_DIR -type f ! -name "*.svg" -delete

# rm -rf $OUTPUT_DIR/*

# The final output file
MERGED_FILE="$OUTPUT_DIR/merged.yml"

# Temporary file for connections
CONNECTIONS_FILE="$OUTPUT_DIR/connections.yml"

# Create an empty merged.yml file
touch $MERGED_FILE
touch $CONNECTIONS_FILE

# Prepare an initial state for merge operation
echo "connectors: {}" >> $MERGED_FILE
echo "cables: {}" >> $MERGED_FILE
echo "connections: []" >> $MERGED_FILE

# Iterate over each yml file in the script directory
for file in $SCRIPT_DIR/*.yml
do
    # Merge the yaml files for connectors and cables
    yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' $MERGED_FILE $file > tmp && mv tmp $MERGED_FILE

    # Extract and append the connections
    yq e '.connections' $file >> $CONNECTIONS_FILE
done

# Append the connections content to the final merged file
echo "connections: " >> $MERGED_FILE
cat $CONNECTIONS_FILE >> $MERGED_FILE

# Print completion message
echo "Merge completed. See merged file in $MERGED_FILE"
