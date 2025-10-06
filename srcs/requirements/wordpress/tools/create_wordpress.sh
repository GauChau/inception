#!/bin/sh

sleep 3

set -e  # Exit immediately if a command exits with a non-zero status

# Check if wp-config.php exists
if [ -f ./wp-config.php ]; then
    echo "WordPress already downloaded"
else
    pwd
    # Download WordPress and all config files
    echo "Downloading WordPress files..."
    wget http://wordpress.org/latest.tar.gz
    rm -rf wp-admin wp-content wp-includes
    tar xfz latest.tar.gz
    mv wordpress/* .
    rm -rf latest.tar.gz
    rm -rf wordpress

    # Check if required environment variables are set
    if [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_HOSTNAME" ] || [ -z "$MYSQL_DB" ]; then
        echo "Error: Mandatory env variables not set."
        exit 1
    fi

    # Import environment variables in the config file
    echo "Configuring wp-config.php..."
    sed -i "s/username_here/$MYSQL_USER/g" wp-config-sample.php
    sed -i "s/password_here/$MYSQL_PASSWORD/g" wp-config-sample.php
    sed -i "s/localhost/$MYSQL_HOSTNAME/g" wp-config-sample.php
    sed -i "s/database_name_here/$MYSQL_DB/g" wp-config-sample.php
    cp wp-config-sample.php wp-config.php

    wp core install --url="${DOMAIN_NAME}" --title="${DOMAIN_TITLE}" \
    --admin_user="${WP_ADMIN_N}" --admin_password="${WP_ADMIN_P}" \
    --admin_email="${WP_ADMIN_MAIL}" --skip-email --allow-root

    wp user create "${WP_U_NAME}" "${WP_U_EMAIL}" --user_pass="${WP_U_PASS}" --role=subscriber --allow-root

fi
exec "$@"