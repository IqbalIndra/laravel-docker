#!/bin/sh

# update application cache
php artisan optimize

# start the application

service php7.2-fpm start &&  nginx -g "daemon off;"


