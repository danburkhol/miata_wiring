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

function get_common_connectors()
{
    $template_file          = ('./src/templates/cable_templates.yml');
    $common_connectors_file = ('./src/common/connectors.yml');

    return Yaml::parse(file_get_contents($template_file) . "\n" . file_get_contents($common_connectors_file));
}


$common_connectors = get_common_connectors();


// export_single_file('./src/cas.yml', $common_connectors);
// export_single_file('./src/ignition.yml', $common_connectors);
