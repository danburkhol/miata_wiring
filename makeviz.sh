#!/bin/bash
# Dependencies
# https://github.com/formatc1702/WireViz
# https://mikefarah.gitbook.io/yq/operators/multiply-merge

rm generated/*

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

yq eval-all '. as $item ireduce ({}; . *+ $item )' \
src/diagram_options.yml \
src/bulkhead.yml \
src/connectors.yml \
src/pmu.yml \
src/ecu.yml \
src/cas.yml \
src/clt.yml \
src/ignition.yml \
src/injectors.yml \
src/knock.yml \
src/lsu.yml \
src/sensors.yml \
src/throttle.yml \
src/oil_pres_sender.yml \
src/shield_drains.yml \
src/sensor_gnd.yml \
> generated/efi.yml

wireviz generated/efi.yml

# cleanup
rm generated/*.gv &> /dev/null
rm generated/*.svg &> /dev/null
rm generated/*.bom.tsv &> /dev/null