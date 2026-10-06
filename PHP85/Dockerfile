# syntax=docker/dockerfile:1

FROM php:8.5-fpm-alpine

# ------------------------------------------------------------
# System dependencies
# ------------------------------------------------------------

RUN apk add --no-cache \
    bash \
    curl \
    git \
    icu-dev \
    imagemagick \
    imagemagick-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    linux-headers \
    oniguruma-dev \
    postgresql-dev \
    freetype-dev \
    unzip \
    zip \
    $PHPIZE_DEPS

# ------------------------------------------------------------
# PHP extensions
# ------------------------------------------------------------

RUN docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    && docker-php-ext-install \
        bcmath \
        exif \
        gd \
        intl \
        mysqli \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        soap \
        sockets \
        xsl \
        zip

# ------------------------------------------------------------
# PECL extensions
# ------------------------------------------------------------

RUN pecl install igbinary \
    && docker-php-ext-enable igbinary \
    && printf 'yes\n\n\n\n\n\n' | pecl install redis \
    && docker-php-ext-enable redis \
    && pecl install imagick \
    && docker-php-ext-enable imagick

# ------------------------------------------------------------
# Composer
# ------------------------------------------------------------

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ------------------------------------------------------------
# PHP
# ------------------------------------------------------------

WORKDIR /var/www

# ------------------------------------------------------------
# PHP-FPM
# ------------------------------------------------------------

CMD ["php-fpm", "-F"]
