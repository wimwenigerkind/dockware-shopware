echo apache2 status:
service apache2 status

CURRENT_PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION . '.' . PHP_MINOR_VERSION;")

echo ""
echo ""
echo "**********************************************"
echo "DOCKWARE CONTAINER STATUS"
echo "**********************************************"
echo ""
echo "PHP: $(php -v | grep cli)"
echo ""
service php${CURRENT_PHP_VERSION}-fpm status
echo ""
php -v
