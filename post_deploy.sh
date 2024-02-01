#!/bin/sh

# update application cache
php artisan optimize

# start the application

service php8.1-fpm start &&  nginx -g "daemon off;"


