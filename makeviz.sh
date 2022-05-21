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
    rm generated/*.gv &> /dev/null
    rm generated/*.svg &> /dev/null
    rm generated/*.bom.tsv &> /dev/null
    rm -r tmp/ &> /dev/null
}

export_master () {
    for src_file in src/*.yml; do
        # make a copy of the source file to inject common items into
        tmp_file_path=tmp/$(basename $src_file)

        sed -r 's/\*/42069/g' $src_file > $tmp_file_path
        echo -e '\n' >> $tmp_file_path
        # cp $src_file $tmp_file_path

        # merges the content of src/common/connector_templates.yml into $tmp_file_path
        sed -i -e '/connectors:/{r src/common/connector_templates.yml' -e 'd}' $tmp_file_path
        # sed -i -e '/cables:/{r src/common/cable_templates.yml' -e 'd}' $tmp_file_path
    done

    sed -ri 's/\*/42069/g' src/common/cable_templates.yml
    cp src/common/cable_templates.yml generated/master.yml
    echo -e '\n' >> generated/master.yml

    yq eval-all '. as $item ireduce ({}; . *+ $item )' tmp/*.yml >> generated/master.yml
    sed -ri 's/42069/\*/g' generated/master.yml

    wireviz generated/master.yml
}

setup
export_master
cleanup
