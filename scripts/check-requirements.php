<?php

if ($argc !== 2) {
    echo "Usage: php check-requirements.php <SHOPWARE_VERSION>\n";
    exit(1);
}

$shopwareVersion = $argv[1];

# check if our svrunit file exists
$svrunitConfig = __DIR__ . '/../tests/svrunit/shopware/' . $shopwareVersion . '.xml';

if (!file_exists($svrunitConfig)) {
    echo "Error: Missing SVRUNIT configuration file for this Shopware version" . PHP_EOL;
    echo $svrunitConfig . PHP_EOL;
    exit(1);
}


exit(0);