FROM ubuntu:latest AS base

# Specify the variable you need
ARG RAILWAY_SERVICE_NAME
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD
ARG APP_URL
ARG PORT
ARG APP_KEY
ARG APP_ENV
ARG RAILWAY_PUBLIC_DOMAIN

ENV DB_HOST=$DB_HOST
ENV DB_PORT=$DB_PORT
ENV DB_DATABASE=$DB_DATABASE
ENV DB_USERNAME=$DB_USERNAME
ENV DB_PASSWORD=$DB_PASSWORD
ENV APP_URL=$APP_URL
ENV APP_KEY=$APP_KEY
ENV PORT=$PORT
ENV APP_ENV=$APP_ENV
ENV COMPOSER_ALLOW_SUPERUSER=1


ENV DEBIAN_FRONTEND noninteractive


# Install dependencies
RUN apt update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt install -y php7.2\
    php7.2-cli\
    php7.2-common\
    php7.2-fpm\
    php7.2-mysql\
    php7.2-zip\
    php7.2-gd\
    php7.2-mbstring\
    php7.2-curl\
    php7.2-xml\
    php7.2-bcmath\
    php7.2-pdo

# Install php-fpm
RUN apt install -y php7.2-fpm php7.2-cli

# Install composer
RUN apt install -y curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install nodejs
RUN apt install -y ca-certificates gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
ENV NODE_MAJOR 20
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN apt update
RUN apt install -y nodejs


# Install nginx
RUN apt install -y nginx


COPY . /var/www/html
WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html

RUN composer install --no-dev --optimize-autoloader

#copy .env from .env.example
RUN composer run-script post-root-package-install

RUN echo "Generating application key..."
RUN php artisan key:generate

RUN php artisan optimize

RUN php artisan route:clear

RUN php artisan route:cache

RUN php artisan config:clear

RUN php artisan config:cache

RUN php artisan view:clear

RUN php artisan view:cache


EXPOSE 80

RUN ["chmod", "+x", "post_deploy.sh"]

CMD [ "sh", "./post_deploy.sh" ]
# CMD php artisan serve --host=127.0.0.1 --port=9000
