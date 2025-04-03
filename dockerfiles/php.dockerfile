FROM php:8.2-fpm-alpine

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

ENV TERM=xterm
ENV ZSH=/root/.oh-my-zsh

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

COPY ./php/php.ini /usr/local/etc/php/
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# MacOS staff group's gid is 20, so is the dialout group in alpine linux. We're not using it, let's just remove it.
RUN delgroup dialout

RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

RUN docker-php-ext-install pdo pdo_mysql

RUN apk update && \
    apk add --no-cache git && \
    apk add mysql mysql-client && \
    rm -f /var/cache/apk/*

RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/5.3.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-install redis

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -t robbyrussell \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-syntax-highlighting

# Install dependencies and intl extension
RUN apk add --no-cache \
        icu-dev \
        build-base \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && apk del build-base

# Install the bcmath extension
RUN docker-php-ext-install bcmath

# Install dependencies for rdkafka and phpize
RUN apk add --no-cache \
        autoconf \
        build-base \
        librdkafka-dev \
        git \
        bash \
    && pecl install rdkafka \
    && docker-php-ext-enable rdkafka \
    && apk del build-base git

# Install dependencies for GD and enable the gd extension
RUN apk add --no-cache \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        libwebp-dev \
    && docker-php-ext-configure gd \
    && docker-php-ext-install gd

# Install dependencies for the zip extension
RUN apk add --no-cache \
        libzip-dev \
        zip \
        build-base \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip \
    && apk del build-base

# Imagisk
RUN apk add $PHPIZE_DEPS && \
    apk add --virtual .imagick-deps imagemagick imagemagick-dev && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    apk del --purge $PHPIZE_DEPS

USER laravel

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
