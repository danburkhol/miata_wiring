#!/bin/bash
# Dependencies
# https://github.com/formatc1702/WireViz
# https://mikefarah.gitbook.io/yq/operators/multiply-merge

# injectors
# yq '. *= load("src/connectors.yml")'  src/injectors.yml > generated/injectors.yml
# wireviz generated/injectors.yml

# # ignition
# yq '. *= load("src/connectors.yml")'  src/ignition.yml > generated/ignition.yml
# wireviz generated/ignition.yml

# # throttle
# yq '. *= load("src/connectors.yml")'  src/throttle.yml > generated/throttle.yml
# wireviz generated/throttle.yml

# # knock
# yq '. *= load("src/connectors.yml")'  src/knock.yml > generated/knock.yml
# wireviz generated/knock.yml

# # lsu
# yq '. *= load("src/connectors.yml")'  src/lsu.yml > generated/lsu.yml
# wireviz generated/lsu.yml

# # ecu
# yq '. *= load("src/connectors.yml")'  src/ecu.yml > generated/ecu.yml
# wireviz generated/ecu.yml

# master
yq eval-all '. as $item ireduce ({}; . *+ $item )' src/*.yml > generated/master.yml
wireviz generated/master.yml

# cleanup
rm generated/*.gv > /dev/null
rm generated/*.svg > /dev/null
rm generated/*.bom.tsv > /dev/null