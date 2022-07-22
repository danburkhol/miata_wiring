<?php

require_once './vendor/autoload.php';

// https://github.com/symfony/yaml
use Symfony\Component\Yaml\Yaml;

function array_keys_recursive($array, $callback_filter = null)
{
    // $keys = array_keys($array);
    // var_export($keys);
    // exit;
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

    // detect the connectors used in this file
    $used_connectors = (
        array_keys_recursive(($parsed_input['connections'] ?? []),
        function($var) {
            return (bool) preg_match('/X-/i', $var);
        }
    ));

    // Inject the connector definitions into the array
    $parsed_input['connectors'] = (
        array_intersect_key(
            $common_connectors,
            array_flip($used_connectors)
        )
    );

    file_put_contents(
        ('./tmp/'.basename($input_file)),
        Yaml::dump($parsed_input)
    );
}

function get_common_connectors()
{
    $template_file          = ('./src/templates/cable_templates.yml');
    $common_connectors_file = ('./src/common/connectors.yml');

    return Yaml::parse(file_get_contents($template_file) . "\n" . file_get_contents($common_connectors_file))['connectors'];
}


$common_connectors = get_common_connectors();


export_single_file('./src/cas.yml', $common_connectors);
