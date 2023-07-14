#!/bin/bash
# yq '. *= load("file2.yml")' file1.yml

# capture path to .yml file as input argument
FILE=$1

# wireviz $1 --prepend-file common.yml

# delete .gv, bom.tsv, and .png files
find . -type f -name "*.gv" -delete
find . -type f -name "*.tsv" -delete
find . -type f -name "*.png" -delete
