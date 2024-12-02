echo "DOCKWARE: activating Xdebug..."

#make sure we use the current running php version and not that one from the ENV
CURRENT_PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;")

sudo mv /etc/php/${CURRENT_PHP_VERSION}/fpm/conf.d/20-xdebug.ini_disabled /etc/php/${CURRENT_PHP_VERSION}/fpm/conf.d/20-xdebug.ini  > /dev/null 2>&1 &
sudo mv /etc/php/${CURRENT_PHP_VERSION}/cli/conf.d/20-xdebug.ini_disabled /etc/php/${CURRENT_PHP_VERSION}/cli/conf.d/20-xdebug.ini  > /dev/null 2>&1 &
wait

sudo sed -i 's/__dockware_host__/'${XDEBUG_REMOTE_HOST}'/g' /etc/php/${CURRENT_PHP_VERSION}/fpm/conf.d/20-xdebug.ini
sudo sed -i 's/__dockware_host__/'${XDEBUG_REMOTE_HOST}'/g' /etc/php/${CURRENT_PHP_VERSION}/cli/conf.d/20-xdebug.ini
wait

sudo service php${CURRENT_PHP_VERSION}-fpm restart > /dev/null 2>&1