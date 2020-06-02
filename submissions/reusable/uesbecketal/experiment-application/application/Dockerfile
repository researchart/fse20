FROM php:7.2-apache

RUN mkdir -p /usr/share/man/man1
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless && \
    apt-get install -y ant  && \
    apt-get clean;

RUN docker-php-ext-install mysqli pdo pdo_mysql
