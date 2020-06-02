# README

## Docker Local Environment

* Make sure docker is installed and running [windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows/), [Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac/), [ubuntu](https://docs.docker.com/engine/install/ubuntu/)
* Run `docker-compose up` in experiment-application folder to start the three containers. This might take a little the first time.
* Access the actual application at http://localhost
* Access phpmyadmin at http://localhost:8080

## Using this in production

* Change the hardcoded values for database passwords and names in
  docker-compose.yml. A good choice for this might be to use environment
  variables and using an .env file.
* Change the database connection configuration in EPI/code/configuration.php to
  fit your database connection values

## Manual Installation

* Install and set-up Apache and PHP 
  - [helpful] (https://coolestguidesontheplanet.com/get-apache-mysql-php-and-phpmyadmin-working-on-osx-10-11-el-capitan/)
* Install MySQL
  - Remember Admin password
  - change Admin password using `mysql -u root -p` and `SET PASSWORD
    = PASSWORD('newpw');`
* Install PhpMyAdmin
  - follow instructions from guide
* initialize database as defined in code/config.php using the sql files in code/sql by creating database `CREATE DATABASE databasename` and then paste the code/sql/concurrency.sql file into the sql console in phpmyadmin
* create user as defined in code/config.php `CREATE USER 'newuser'@'localhost' IDENTIFIED BY 'password';`
* give user rights `GRANT ALL PRIVILEGES ON databasename . * TO 'newuser'@'localhost';`
* create tmp/ folder in EPI/
* use 'fixrights.sh' file to fix the rights on the tmp/ folder. 
* make sure ant is installed



