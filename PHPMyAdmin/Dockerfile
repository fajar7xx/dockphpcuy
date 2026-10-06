# syntax=docker/dockerfile:1

# ------------------------------------------------------------------
# Stage 1: fetch the phpMyAdmin theme from files.phpmyadmin.net
# ------------------------------------------------------------------
FROM alpine:3.21 AS theme

ARG PMA_THEME=boodark
ARG PMA_THEME_VERSION=1.2.0

RUN apk add --no-cache curl unzip \
    && curl -fsSL \
        "https://files.phpmyadmin.net/themes/${PMA_THEME}/${PMA_THEME_VERSION}/${PMA_THEME}-${PMA_THEME_VERSION}.zip" \
        -o /tmp/theme.zip \
    && mkdir -p /themes \
    && unzip -q /tmp/theme.zip -d /themes \
    && rm -f /tmp/theme.zip

# ------------------------------------------------------------------
# Stage 2: phpMyAdmin + theme + user config
# ------------------------------------------------------------------
FROM phpmyadmin:latest

COPY --from=theme /themes/ /var/www/html/themes/
COPY config.user.inc.php /etc/phpmyadmin/config.user.inc.php
