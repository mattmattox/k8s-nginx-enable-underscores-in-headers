FROM ubuntu:18.04

MAINTAINER matthew.mattox@rancher.com

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    apt-utils \
    curl \
    apache2 \
    libapache2-mod-php7.2 \
    php7.2-cli \
    php7.2-json \
    php7.2-curl \
    php7.2-fpm \
    php7.2-mbstring \
    openssl \
    nano \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

##Set locales
RUN locale-gen en_US.UTF-8 en_GB.UTF-8 de_DE.UTF-8 es_ES.UTF-8 fr_FR.UTF-8 it_IT.UTF-8 km_KH sv_SE.UTF-8 fi_FI.UTF-8

##Configure PHP
ADD phpsettings.ini /etc/php/7.2/mods-available/
RUN phpenmod phpsettings
RUN a2enmod rewrite expires
RUN echo "ServerName localhost" | tee /etc/apache2/conf-available/servername.conf
RUN a2enconf servername

##Configure Apache
ADD apache.conf /etc/apache2/sites-available/
RUN a2dissite 000-default
RUN a2ensite apache.conf
RUN ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/error.log

EXPOSE 80

WORKDIR /var/www/src
ADD public_html /var/www/src

CMD apachectl -D FOREGROUND
