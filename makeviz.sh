#!/bin/bash
# Dependencies
# https://github.com/formatc1702/WireViz
# https://mikefarah.gitbook.io/yq/operators/multiply-merge


setup() {
    mkdir generated &> /dev/null
    rm generated/* &> /dev/null
    mkdir tmp &> /dev/null
    rm -r tmp/* &> /dev/null
}

cleanup() {
    # rm generated/*.gv &> /dev/null
    rm generated/*.svg &> /dev/null
    rm generated/*.bom.tsv &> /dev/null
    rm -r tmp/ &> /dev/null
}

strip_anchors() {
    # Remove asterisk from anchors to make yaml merging easier
    # Store it in the given dir $2 with a new line
    sed -r 's/\*/42069/g' $1 > $2
    echo -e '\n' >> $2
}

restore_anchors() {
    sed -ri 's/42069/\*/g' $1
}

export_file() {
    src_file=$1
    generated_file=$2

    tmp_file_path=tmp/$(basename $src_file)

    strip_anchors $src_file $tmp_file_path

    # Seed the generated file
    strip_anchors src/templates/cable_templates.yml $generated_file

    # merge the src file into the templated file
    yq eval-all '. as $item ireduce ({}; . *+ $item )' tmp/*.yml >> $generated_file

    restore_anchors $generated_file

    wireviz $generated_file

    cleanup
}


export_master () {
    for src_file in src/*.yml; do
        # make a copy of the source file to inject common items into
        tmp_file_path=tmp/$(basename $src_file)

        strip_anchors $src_file $tmp_file_path
    done

    strip_anchors src/templates/cable_templates.yml generated/master.yml

    yq eval-all '. as $item ireduce ({}; . *+ $item )' tmp/*.yml >> generated/master.yml
    restore_anchors generated/master.yml

    wireviz generated/master.yml

    if whoami | grep -q "danburkhol"; then
        # Copy to dropbox for an accessible copy on mobile
        cp generated/master.png ~/Dropbox/master_wiring_digram.png
    fi
}

setup
export_master
cleanup

export_file src/steering_column.yml generated/steering_column.yml