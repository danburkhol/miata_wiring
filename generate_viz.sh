#!/bin/bash
# Dependencies
# https://github.com/formatc1702/WireViz
# https://github.com/alexlafroscia/yaml-merge

yaml-merge src/*.yml > generated/merged.yml
wireviz generated/merged.yml