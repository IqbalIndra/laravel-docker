# 2022 update
FROM php:7.2-fpm

# setup user as root
USER root

WORKDIR /var/www/html

# setup node js source will be used later to install node js



# PS. you can deploy an image that stops at this step so that your cI/CD builds are a bit faster (if not cached) this is what takes the most time in the deployment process.
RUN apt-get update \
    # gd
    && apt-get install -y build-essential  openssl nginx libfreetype6-dev libjpeg-dev libpng-dev libwebp-dev zlib1g-dev libzip-dev gcc g++ make vim unzip curl git jpegoptim optipng pngquant gifsicle locales libonig-dev nodejs  \
    && docker-php-ext-configure gd  \
    && docker-php-ext-install gd \
    # gmp
    && apt-get install -y --no-install-recommends libgmp-dev \
    && docker-php-ext-install gmp \
    # pdo_mysql
    && docker-php-ext-install pdo_mysql mbstring \
    # pdo
    && docker-php-ext-install pdo \
    # opcache
    && docker-php-ext-enable opcache \
    # exif
    && docker-php-ext-install exif \
    && docker-php-ext-install sockets \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install bcmath \
    # zip
    && docker-php-ext-install zip \
    && apt-get autoclean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/pear/


# Copy files
COPY . /var/www/html

COPY ./deploy/local.ini /usr/local/etc/php/local.ini

COPY ./deploy/conf.d/nginx.conf /etc/nginx/nginx.conf

RUN chmod +rwx /var/www/html

RUN chmod -R 777 /var/www/html

# setup composer and laravel
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN composer install --no-dev --optimize-autoloader

RUN composer dump-autoload 

RUN php artisan optimize

RUN php artisan route:clear

RUN php artisan route:cache

RUN php artisan config:clear

RUN php artisan config:cache

RUN php artisan view:clear

RUN php artisan view:cache

# remove this line if you do not want to run migrations on each build
#RUN php artisan migrate --force

EXPOSE 80

RUN ["chmod", "+x", "post_deploy.sh"]

CMD [ "sh", "./post_deploy.sh" ]
# CMD php artisan serve --host=127.0.0.1 --port=9000
