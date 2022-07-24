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

function export_wireviz($file_path, $dest = null)
{
    if (!file_exists('./tmp')) mkdir('./tmp');

    exec('wireviz ./tmp/'.basename($file_path));
}

function export_master($tmp_file_path = './tmp/master.yml')
{
    if (!file_exists('./tmp')) mkdir('./tmp');
    $global_config = generate_global_config();

    file_put_contents($tmp_file_path, Yaml::dump($global_config));

    export_wireviz($tmp_file_path);
}

export_master();