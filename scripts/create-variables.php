<?php

if ($argc !== 2) {
    echo "Usage: php createVariablesJson.php <SHOPWARE_VERSION>\n";
    exit(1);
}

$shopwareVersion = $argv[1];

// Define the fixed structure
$data = [
    "php" => [
        "8.4",
        "8.3"
    ],
    "node" => [
        "22"
    ],
    "shopware" => $shopwareVersion
];

// Path to the JSON file
$filePath = __DIR__ . '/../src/config/variables.json';

// Create the directory if it doesn't exist
if (!is_dir(dirname($filePath))) {
    mkdir(dirname($filePath), 0777, true);
}

// Write the JSON data to the file
file_put_contents($filePath, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

echo "JSON file created at $filePath\n";