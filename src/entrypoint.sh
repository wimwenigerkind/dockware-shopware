#!/bin/bash

echo ""
echo " _____   ____   _____ _  ____          __     _____  ______ "
echo "|  __ \ / __ \ / ____| |/ /\ \        / /\   |  __ \|  ____|"
echo "| |  | | |  | | |    | ' /  \ \  /\  / /  \  | |__) | |__   "
echo "| |  | | |  | | |    |  <    \ \/  \/ / /\ \ |  _  /|  __|  "
echo "| |__| | |__| | |____| . \    \  /\  / ____ \| | \ \| |____ "
echo "|_____/ \____/ \_____|_|\_\    \/  \/_/    \_\_|  \_\______|"
echo ""
echo "68 69 20 64 65 76 65 6C 6F 70 65 72 2C 20 6E 69 63 65 20 74 6F 20 6D 65 65 74 20 79 6F 75"
echo "6c 6f 6f 6b 69 6e 67 20 66 6f 72 20 61 20 6a 6f 62 3f 20 77 72 69 74 65 20 75 73 20 61 74 20 6a 6f 62 73 40 64 61 73 69 73 74 77 65 62 2e 64 65"
echo ""
echo "*******************************************************"
echo "** DOCKWARE IMAGE: flex"
echo "** Version: $(cat /dockware/version.txt)"
echo "** Built: $(cat /dockware/build-date.txt)"
echo "** Copyright $(cat /dockware/copyright.txt)"
echo "*******************************************************"
echo ""
echo "launching dockware...please wait..."
echo ""

set -e


source /etc/apache2/envvars
source /var/www/.bashrc

# this is important to automatically use the bashrc file
# in the "exec" command below when using a simple docker runner command
export BASH_ENV=/var/www/.bashrc

CONTAINER_STARTUP_DIR=$(pwd)

# only do all our stuff
# if we are not in recovery mode
if [ $RECOVERY_MODE = 0 ]; then

    # it's possible to add a custom boot script on startup.
    # so we test if it exists and just execute it
    file="/var/www/boot_start.sh"
    if [ -f "$file" ] ; then
        sh $file
    fi

    echo "DOCKWARE: setting timezone to ${TZ}..."
    sudo ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
    sudo dpkg-reconfigure -f noninteractive tzdata
    echo "-----------------------------------------------------------"

    # checks if a different username is set in ENV and create if its not existing yet
    if [ $SSH_USER != "not-set" ] && (! id -u "${SSH_USER}" >/dev/null 2>&1 ); then
        echo "DOCKWARE: creating additional SSH user...."
        sh /var/www/scripts/bin/add_user.sh $SSH_USER $SSH_PWD
        echo "-----------------------------------------------------------"
    fi

    # start the SSH service with the latest setup
    echo "DOCKWARE: restarting SSH service...."
    sudo service ssh restart
    echo "-----------------------------------------------------------"

    echo "DOCKWARE: starting cron service...."
    sudo service cron start
    echo "-----------------------------------------------------------"

    if [ "$NODE_VERSION" != "not-set" ]; then
       echo "DOCKWARE: switching to Node ${NODE_VERSION}..."
       nvm alias default ${NODE_VERSION}
       # now make sure to at least have node and npm as sudo
       # nvm itself is not possible by design
       sudo rm -f /usr/local/bin/node
       sudo rm -f /usr/local/bin/npm
       sudo ln -s "$(which node)" "/usr/local/bin/node"
       sudo ln -s "$(which npm)" "/usr/local/bin/npm"
       echo "-----------------------------------------------------------"
    fi

    if [ "$PHP_VERSION" != "not-set" ]; then
      echo "DOCKWARE: switching to PHP ${PHP_VERSION}..."
      cd /var/www && make switch-php version=${PHP_VERSION}
      echo "-----------------------------------------------------------"
    else
      CURRENT_PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;")
      echo "DOCKWARE: Using default PHP version ${CURRENT_PHP_VERSION}..."
      cd /var/www && make switch-php version=${CURRENT_PHP_VERSION}
    fi

    sudo service apache2 stop

    CURRENT_PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;")

    # somehow we (once) had the problem that composer does not find a HOME directory this was the solution
    export COMPOSER_HOME=/var/www

    if [ $XDEBUG_ENABLED = 1 ]; then
       sh /var/www/scripts/bin/xdebug_enable.sh
     else
       sh /var/www/scripts/bin/xdebug_disable.sh
    fi

    if [ $TIDEWAYS_KEY != "not-set" ]; then
        echo "DOCKWARE: activating Tideways...."
        sudo sed -i 's/__DOCKWARE_VAR_TIDEWAYS_API_KEY__/'${TIDEWAYS_KEY}'/g' /etc/php/${CURRENT_PHP_VERSION}/fpm/conf.d/20-tideways.ini
        sudo sed -i 's/__DOCKWARE_VAR_TIDEWAYS_API_KEY__/'${TIDEWAYS_KEY}'/g' /etc/php/${CURRENT_PHP_VERSION}/cli/conf.d/20-tideways.ini
        nohup sudo tideways-daemon --log=/var/log/tideways/daemon.log > /dev/null 2>&1 &
        ps aux | grep tideways-daemon
        echo "-----------------------------------------------------------"
    fi

    echo "DOCKWARE: starting MySQL...."
    file="/var/run/mysqld/mysqld.sock.lock"
    if [ -f "$file" ] ; then
        sudo rm -f "$file"
    fi
    sudo chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
    #sudo service mysql start;

    # --------------------------------------------------
    # APACHE
    # first set the correct doc root, because we need it for the php switch below
    sudo sed -i 's#__dockware_apache_docroot__#'${APACHE_DOCROOT}'#g' /etc/apache2/sites-enabled/000-default.conf
    sudo sed -i 's#__dockware_php_version__#'${CURRENT_PHP_VERSION}'#g' /etc/apache2/sites-enabled/000-default.conf
    # sometimes the internal docker structure leaves
    # some pid files existing. the container will be recreated....but
    # in reality it's not! thus there might be the problem
    # that an older pid file exists, which leads to the following error:
    #   - "httpd (pid 13) already running"
    # to avoid this, we simple remove an existing file
    sudo rm -f /var/run/apache2/apache2.pid
    # also, sometimes port 80 is used? happens if you have lots of local containers i think
    # so let's just kill that, otherwise the container won't start
    sudo lsof -t -i tcp:80 | sudo xargs kill >/dev/null 2>&1 || true;

    # start test and start apache
    echo "DOCKWARE: testing and starting Apache..."
    sudo apache2ctl configtest
    sudo service apache2 restart
    echo "-----------------------------------------------------------"
    # --------------------------------------------------


    if [ $FILEBEAT_ENABLED = 1 ]; then
       echo "DOCKWARE: activating Filebeat..."
       sudo service filebeat start --strict.perms=false
       echo "-----------------------------------------------------------"
    fi

    if [ $SUPERVISOR_ENABLED = 1 ]; then
         echo "DOCKWARE: activating Supervisor..."
         sudo service supervisor start
         echo "-----------------------------------------------------------"
    fi


    # before starting any commands
    # we always need to ensure we are back in our
    # configured WORKDIR of the container
    echo "-----------------------------------------------------"
    cd $CONTAINER_STARTUP_DIR

    # now let's check if we have a custom boot script that
    # should run after our other startup scripts.
    file="/var/www/boot_end.sh"
    if [ -f "$file" ] ; then
        sh $file
    fi

    echo ""
    echo "WOHOOO, container IS READY :) - let's get started"
    echo "-----------------------------------------------------"
    echo "PHP: $(php -v | grep cli)"
    echo "Apache DocRoot: ${APACHE_DOCROOT}"

else

    echo ""
    echo "Dockware has been started in RECOVERY_MODE."
    echo "Nothing has been executed or initialized..."
    echo ""

    # build the recovery mode file (for SVRUnit Tests
    echo "enabled" > /var/www/recovery.txt

fi

# always execute custom commands in here.
# if a custom command is provided, then the container
# will automatically exit after it.
# that's somehow just how it works.
# otherwise it will continue with the code below
exec "$@"

# we still need this to allow custom events
# such as our BUILD_PLUGIN feature to exit the container
if [[ ! -z "$DOCKWARE_CI" ]]; then
    # CONTAINER WAS STARTED IN NON-BLOCKING CI MODE...."
    # DOCKWARE WILL NOW EXIT THE CONTAINER"
    echo ""
else
    tail -f /dev/null
fi

