FROM php:7.3-fpm

MAINTAINER Ary Wibowo (nucreativa@gmail.com)

# Get repository and install wget and vim
RUN apt-get update && apt-get install --no-install-recommends -y \
		apt-utils \
        wget \
        gnupg \
        git \
        unzip \
        curl \
        apt-transport-https

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list

# Install PHP extensions deps
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmagickwand-dev \
        imagemagick \
        libmcrypt-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        unixodbc-dev \
        libxml2-dev \
        libaio-dev \
        libmemcached-dev \
        freetds-dev \
        libssl-dev \
        openssl \
        libzip-dev \
        unixodbc-dev \
        mariadb-client

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- \
        --install-dir=/usr/local/bin \
        --filename=composer

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure pdo_dblib --with-libdir=/lib/x86_64-linux-gnu \
    && docker-php-ext-configure intl \
    && pecl install sqlsrv-5.6.1 \
    && pecl install pdo_sqlsrv-5.6.1 \
    && pecl install redis \
    && pecl install memcached \
    && pecl install xdebug \
    && pecl install imagick \
    && pecl install mcrypt-1.0.3 \
    && docker-php-ext-install \
            iconv \
            mbstring \
            intl \
            gd \
            mysqli \
            pdo_mysql \
            pdo_dblib \
            soap \
            sockets \
            zip \
            pcntl \
            ftp \
            bcmath \
    && docker-php-ext-enable \
            sqlsrv \
            pdo_sqlsrv \
            redis \
            memcached \
            opcache \
            imagick \
            xdebug

# Install APCu and APC backward compatibility
RUN pecl install apcu \
    && pecl install apcu_bc-1.0.5 \
    && docker-php-ext-enable apcu --ini-name 10-docker-php-ext-apcu.ini \
    && docker-php-ext-enable apc --ini-name 20-docker-php-ext-apc.ini

# Clean repository
RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
RUN chown -R www-data:www-data /var/www
