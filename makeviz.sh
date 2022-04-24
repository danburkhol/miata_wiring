#!/bin/bash
# Dependencies
# https://github.com/formatc1702/WireViz
# https://mikefarah.gitbook.io/yq/operators/multiply-merge

# generic
yq '. *= load("src/connectors.yml")' src/connectors_efi.yml > generated/connectors_efi.yml

# injectors
yq '. *= load("generated/connectors_efi.yml")'  src/injectors.yml > generated/injectors.yml
wireviz generated/injectors.yml

# ignition
yq '. *= load("generated/connectors_efi.yml")'  src/ignition.yml > generated/ignition.yml
wireviz generated/ignition.yml

# throttle
yq '. *= load("generated/connectors_efi.yml")'  src/throttle.yml > generated/throttle.yml
wireviz generated/throttle.yml

# knock
yq '. *= load("generated/connectors_efi.yml")'  src/knock.yml > generated/knock.yml
wireviz generated/knock.yml

# lsu
yq '. *= load("generated/connectors_efi.yml")'  src/lsu.yml > generated/lsu.yml
wireviz generated/lsu.yml