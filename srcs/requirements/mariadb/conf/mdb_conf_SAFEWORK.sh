#!/bin/bash
set -e

# Initialiser MariaDB si la base n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi


# Lancer MariaDB en arrière-plan
mysqld_safe --datadir=/var/lib/mysql &
# exec su mysql -s /bin/bash "$0" "$@"

#echo "Waiting for MariaDB to be 1111"
# Attendre que le serveur soit dispo
until mysqladmin ping -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent; do
    echo ping res: $?
    echo "Waiting for MariaDB to be ready..."
    sleep 1
done

# Sécuriser et créer la base + utilisateur
if ! mysql  -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${MYSQL_DB}"; then
    echo "Setting up MariaDB..."
    mysql  -p"${MYSQL_ROOT_PASSWORD}" <<END
    -- Set root password and disable remote root login
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    -- DELETE FROM mysql.user WHERE User=''; -- Remove anonymous users
    -- DROP DATABASE IF EXISTS test; -- Remove test database
    FLUSH PRIVILEGES;

    -- Allow root to connect from any host
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;

    -- Create initial database and user with privileges
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DB};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
END
fi
# Arrêter MariaDB (il sera relancé par CMD)
mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Lancer le vrai processus (mysqld)
exec "$@"