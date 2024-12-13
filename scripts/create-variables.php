<?php

if ($argc !== 2) {
    echo "Usage: php createVariablesJson.php <SHOPWARE_VERSION>\n";
    exit(1);
}

$shopwareVersion = $argv[1];

// Path to the shopware-overview.json file
$overviewFilePath = __DIR__ . '/shopware-overview.json';

// Check if the shopware-overview.json file exists
if (!file_exists($overviewFilePath)) {
    echo "Error: shopware-overview.json not found.\n";
    exit(1);
}

// Decode the JSON file
$overviewData = json_decode(file_get_contents($overviewFilePath), true);

// Check if the specified Shopware version exists in the overview
if (!isset($overviewData[$shopwareVersion])) {
    echo "Error: Shopware version $shopwareVersion not found in shopware-overview.json.\n";
    exit(1);
}

// Extract PHP and Node values for the specified version
$phpVersions = $overviewData[$shopwareVersion]['php'] ?? [];
$nodeVersions = $overviewData[$shopwareVersion]['node'] ?? [];

// Define the data for variables.json
$data = [
    "php" => $phpVersions,
    "node" => $nodeVersions,
    "shopware" => $shopwareVersion
];

// Path to the variables.json file
$variablesFilePath = __DIR__ . '/../src/config/variables.json';

// Create the directory if it doesn't exist
if (!is_dir(dirname($variablesFilePath))) {
    mkdir(dirname($variablesFilePath), 0777, true);
}

// Write the JSON data to the variables.json file
file_put_contents($variablesFilePath, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));

echo "variables.json created successfully at $variablesFilePath\n";