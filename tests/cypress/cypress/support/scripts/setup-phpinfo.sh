
docker exec shopware_cypress bash -c "cd /var/www/html/public && rm -rf *"

docker exec shopware_cypress bash -c "cd /var/www/html/public && echo '<?php phpinfo();' > index.php"
