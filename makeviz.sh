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


wireviz --prefix-file src/connectors_efi.yml src/injectors.yml -o generated/injectors