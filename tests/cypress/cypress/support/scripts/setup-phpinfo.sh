
docker exec flex_cypress bash -c "cd /var/www/html/public && rm -rf *"

docker exec flex_cypress bash -c "cd /var/www/html/public && echo '<?php phpinfo();' > index.php"
