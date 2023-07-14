#!/bin/bash

wireviz interior_connectors.yml --prepend-file interior_cables.yml
wireviz engine_bay.yml --prepend-file engine_bay_connections.yml

# delete .gv, bom.tsv, and .png files
find . -type f -name "*.gv" -delete
find . -type f -name "*.tsv" -delete
find . -type f -name "*.png" -delete
