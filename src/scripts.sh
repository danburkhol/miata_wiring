#!/bin/bash
# yq '. *= load("file2.yml")' file1.yml

# make a subdirectory called `generated` if it doesn't exist
mkdir generated &> /dev/null

# capture path to .yml file as input argument
FILE=$1

# get the filename without the extension from the input argument
FILENAME=$(basename -- "$FILE")

wireviz $1 -o generated/$FILENAME --prepend-file templates/templates.yml

# wireviz $1 --prepend-file common.yml

# delete .gv, bom.tsv, and .png files
find . -type f -name "*.gv" -delete
find . -type f -name "*.tsv" -delete
find . -type f -name "*.png" -delete
find . -type f -name "*.html" -delete