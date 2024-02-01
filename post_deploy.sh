#!/bin/sh

# update application cache
php artisan optimize
php artisan serve --port:80

# start the application

#service php8.1-fpm start &&  nginx -g "daemon off;"


