<?php

require_once './vendor/autoload.php';

// https://github.com/symfony/yaml
use Symfony\Component\Yaml\Yaml;

function array_keys_recursive($array, $callback_filter = null)
{
    if (is_callable($callback_filter)) {
        $keys = array_filter(array_keys($array), $callback_filter);
    } else {
        $keys = array_keys($array);
    }
    foreach ($array as $i)
      if (is_array($i))
        $keys = array_merge($keys, array_keys_recursive($i, $callback_filter));

    return $keys;
}

function export_single_file($input_file, $common_connectors = [])
{
    $parsed_input = Yaml::parseFile($input_file);
    if (empty($parsed_input['connections'])) return;

    // detect the connectors used in this file
    $used_connectors = (
        array_keys_recursive(($parsed_input['connections'] ?? []),
        function($var) {
            return (bool) preg_match('/X-/i', $var);
        }
    ));
    // Capture connector connections that are simple
    array_walk_recursive($parsed_input['connections'], function($item) use (&$used_connectors) {
        if ((bool) preg_match('/X-/i', $item)) {
            $used_connectors[] = $item;
        }
    });

    // Inject the connector definitions into the array
    $parsed_input['connectors'] = (
        array_intersect_key(
            $common_connectors['connectors'],
            array_flip(array_unique($used_connectors))
        )
    );

    // Inject the templates
    $parsed_input['templates'] = $common_connectors['templates'];

    file_put_contents(
        ('./tmp/'.basename($input_file)),
        Yaml::dump($parsed_input)
    );
}

/**
 * Concatonate an array of files into a single body and parse that as a yaml file
 * Order of $files matters, each subsequent file is appended to the last
 * @param array(string) $files
 * @return array
 */
function concat_and_parse_yaml_files($files)
{
    return Yaml::parse(
        array_reduce($files, function($out, $file) {
            return (
                $out."\n".file_get_contents($file)
                // file_get_contents($file)."\n".$out
            );
        }, '')
    );
}

function get_common_connectors()
{
    return concat_and_parse_yaml_files([
        './src/templates/cable_templates.yml',
        './src/common/connectors.yml',
    ]);
}

function merge_yaml_arrays($arr1, $arr2)
{
    $out = [];
    foreach (['connectors', 'cables', 'connections'] as $key) {
        $out[$key] = array_merge(
            ($arr1[$key] ?? []),
            ($arr2[$key] ?? []),
            ($out[$key] ?? [])
        );
    }
    return $out;
}
/**
 * Generate a global config of all source and template files merged together
 * can be exported as-is or used to fill in gaps of other source files for individual export
 * @return array
 */
function generate_global_config()
{
    $template_file     = ('./src/templates/cable_templates.yml');
    $common_connectors = get_common_connectors();

    return array_reduce(
        glob('./src/*.yml'),
        function($out, $file_path) use ($template_file, $common_connectors) {
            $tmp = concat_and_parse_yaml_files([
                $template_file,
                $file_path,
            ]);

            foreach (['connectors', 'cables', 'connections'] as $key) {
                $out[$key] = array_merge(
                    ($tmp[$key] ?? []),
                    ($common_connectors[$key] ?? []),
                    ($out[$key] ?? [])
                );
            }
            return $out;
        },
        []
    );
}

function export_wireviz($file_path, $dest_filename = null)
{
    if (!file_exists('./tmp')) mkdir('./tmp');

    if (empty($dest_filename)) {
        $dest_filename = str_ireplace('.yml', '', basename($file_path));
    }

    exec('wireviz --prepend-file ./src/diagram_options.yml ./tmp/'.basename($file_path).' -o ./generated/'.$dest_filename);
}

function export_master($tmp_file_path = './tmp/master.yml')
{
    if (!file_exists('./tmp')) mkdir('./tmp');
    $global_config = generate_global_config();

    file_put_contents($tmp_file_path, Yaml::dump($global_config));

    export_wireviz($tmp_file_path);
}

function find_missing_definitions($keys_to_find)
{
    $global_config = generate_global_config();

    // Retrieve the definitions of the $keys_to_find
    return array_reduce(
        $keys_to_find,
        function($out, $item) use ($global_config) {
            $type = ((stripos($item, 'x-') !== false) ? 'connectors' : 'cables');

            if (!isset($global_config[$type][$item])) return $out;

            $out[$type][$item] = $global_config[$type][$item];
            return $out;
        },
        []
    );
}

function export_individual($file)
{
    if (!file_exists('./tmp')) mkdir('./tmp');

    $tmp = concat_and_parse_yaml_files([
        ('./src/templates/cable_templates.yml'),
        $file
    ]);

    if (empty($tmp['connections'])) return; // Nothing to do
    $tmp_path = './tmp/'.basename($file);

    file_put_contents($tmp_path, Yaml::dump(inject_undefined_assets($tmp)));

    export_wireviz($tmp_path);
}

function inject_undefined_assets($tmp)
{
    $cables_and_connectors = array_unique(array_keys_recursive(
        ($tmp['connections'] ?? []),
        function($var) {return !is_numeric($var);}
    ));

    return merge_yaml_arrays($tmp, find_missing_definitions($cables_and_connectors));
}

/**
 * Export a set of files with a specific output filename
 *
 * @param array(string) $files
 * @param string $output_file_name
 * @return void
 */
function export_set($files, $output_file_name)
{
    if (!file_exists('./tmp')) mkdir('./tmp');

    $merged = [];

    $merged = array_reduce(
        $files,
        function($out, $file) {
            $tmp = concat_and_parse_yaml_files([
                ('./src/templates/cable_templates.yml'),
                $file
            ]);

            return merge_yaml_arrays($out, inject_undefined_assets($tmp));
        },
        []
    );

    $tmp_path = './tmp/'.basename($output_file_name);

    file_put_contents($tmp_path, Yaml::dump($merged));

    export_wireviz($tmp_path);
}

function export_all()
{
    foreach (glob('./src/*.yml') as $file) {
        export_individual($file);
    }
}

function cleanup()
{
    array_map('unlink', array_merge(
        glob('./tmp/*'),
        glob('./generated/*.png'),
        glob('./generated/*.html'),
        glob('./generated/*.tsv'),
        glob('./generated/*.gv'),
        glob('./generated/*.yml')
    ));
    rmdir('./tmp');
}

/**
 * Generated a basic HTML file with relative links to each generated svg file for easy reference
 *
 * @param string $dest
 * @return void
 */
function generate_home_file($dest = './generated/home.html')
{
    file_put_contents(
        $dest,
        implode(
            "</br>",
            array_reduce(
                glob('./generated/*.svg'),
                function($out, $item) {
                    $href = str_ireplace('generated/', '', $item);
                    $out[] = '<a href="'.$href.'">'.basename($item).'</a>';
                    return $out;
                },
                []
            )
        )
    );
}


$file_to_export = ($argv[1] ?? null);
if (!empty($file_to_export)) {
    if (!file_exists($file_to_export)) {
        echo ("File does not exist: ".$file_to_export);
        exit;
    }
    export_individual($file_to_export);

    echo ("Exported: ".$file_to_export);

    cleanup();
    generate_home_file();
    exit;
}

export_all();
export_master();

foreach (json_decode(file_get_contents('./subsystems.json'), true) as $subsys) {
    export_set($subsys['files'], $subsys['filename']);
}

cleanup();
generate_home_file();