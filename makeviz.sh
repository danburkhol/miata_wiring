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
    setup

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
    setup

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

    cleanup
}

# export_master

# export_file src/5v_supply.yml generated/5v_supply.yml
# export_file src/ac.yml generated/ac.yml
# export_file src/ait.yml generated/ait.yml
# export_file src/alternator.yml generated/alternator.yml
# export_file src/body_grounds.yml generated/body_grounds.yml
# export_file src/brake_light.yml generated/brake_light.yml
# export_file src/bulkhead.yml generated/bulkhead.yml
# export_file src/cas.yml generated/cas.yml
# export_file src/clt.yml generated/clt.yml
# export_file src/clutch_brake_sw.yml generated/clutch_brake_sw.yml
# export_file src/connectors.yml generated/connectors.yml
# export_file src/dashboard.yml generated/dashboard.yml
# export_file src/diagram_options.yml generated/diagram_options.yml
# export_file src/door_locks.yml generated/door_locks.yml
# export_file src/easyguard.yml generated/easyguard.yml
# export_file src/ecu.yml generated/ecu.yml
# export_file src/fan.yml generated/fan.yml
# export_file src/fusebox.yml generated/fusebox.yml
# export_file src/grounds.yml generated/grounds.yml
# export_file src/headlamps.yml generated/headlamps.yml
# export_file src/ignition.yml generated/ignition.yml
# export_file src/injectors.yml generated/injectors.yml
# export_file src/knock.yml generated/knock.yml
# export_file src/lsu.yml generated/lsu.yml
# export_file src/oil_pres_sender.yml generated/oil_pres_sender.yml
# export_file src/pedal.yml generated/pedal.yml
# export_file src/pmu.yml generated/pmu.yml
# export_file src/power_steering.yml generated/power_steering.yml
# export_file src/rear_body.yml generated/rear_body.yml
# export_file src/retractors.yml generated/retractors.yml
# export_file src/sensor_gnd.yml generated/sensor_gnd.yml
# export_file src/sensors.yml generated/sensors.yml
# export_file src/shield_drains.yml generated/shield_drains.yml
# export_file src/steering_column.yml generated/steering_column.yml
# export_file src/throttle.yml generated/throttle.yml
# export_file src/tns.yml generated/tns.yml
# export_file src/transmission_sw.yml generated/transmission_sw.yml
# export_file src/turn_signal.yml generated/turn_signal.yml
# export_file src/wiper.yml generated/wiper.yml

# for src_file in src/*.yml; do
#     # make a copy of the source file to inject common items into
#     tmp_file_path=tmp/$(basename $src_file)
#     generated_file=generated/$(mcbasename $src_file)

#     export_file $src_file $generated_file
#     # strip_anchors $src_file $tmp_file_path
# done

# define an array of file names: foobar.yml, fizzbuzz.yml
new_files=(
    'fusebox.yml'
    'dashbulkhead.yml'
    'mce18.yml'
);

# Iterate over a list of new_files
# wireviz src/{filename.yml} -o generated/{filename.yml}
for file in "${new_files[@]}"; do
    wireviz src/$file -o generated/$file
done
