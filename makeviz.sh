#!/bin/bash
# Dependencies
# https://github.com/formatc1702/WireViz
# https://mikefarah.gitbook.io/yq/operators/multiply-merge

# yq eval-all '. as $item ireduce ({}; . * $item )' *.yml > generated/merged.yml
# wireviz generated/merged.yml

# yaml-merge src/connectors.yml src/ecu_to_bulkhead.yml > generated/ecu_to_bulkhead.yml
# wireviz generated/ecu_to_bulkhead.yml

# yaml-merge src/connectors.yml src/injectors.yml > generated/injectors.yml
# wireviz generated/injectors.yml

# rm generated/merged2.yml
# cd src/
# yq eval-all '. as $item ireduce ({}; . * $item )' *.yml > ../../generated/merged2.yml
# cd ../..
# wireviz generated/merged2.yml

# injectors
yq '. *= load("src/connectors.yml")' src/connectors_efi.yml > generated/connectors_efi.yml
yq '. *= load("generated/connectors_efi.yml")'  src/injectors.yml > generated/injectors.yml
wireviz generated/injectors.yml

# ignition
yq '. *= load("src/connectors.yml")' src/connectors_efi.yml > generated/connectors_efi.yml
yq '. *= load("generated/connectors_efi.yml")'  src/ignition.yml > generated/ignition.yml
wireviz generated/ignition.yml

yq '. *= load("src/connectors.yml")' src/connectors_efi.yml > generated/connectors_efi.yml
yq '. *= load("generated/connectors_efi.yml")'  src/throttle.yml > generated/throttle.yml
wireviz generated/throttle.yml

# wireviz -o generated/injectors/ generated/injectors.yml
# wireviz -o generated/injectors \
# --prepend-file generated/connectors_efi.yml \
# src/injectors.yml
