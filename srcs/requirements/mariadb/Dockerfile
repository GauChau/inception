FROM debian:bookworm

# Installer MariaDB et utilitaires
RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Copier le script d'initialisation
COPY ./conf/mdb_conf.sh /usr/local/bin/mdb_conf.sh

RUN chmod +x /usr/local/bin/mdb_conf.sh && \
chown mysql:mysql /usr/local/bin/mdb_conf.sh && \
mkdir -p /run/mysqld && chown -R mysql:mysql /run/mysqld

# Exposer le port MariaDB
EXPOSE 3306
USER mysql

# Point d'entrée -> script de config
ENTRYPOINT ["/usr/local/bin/mdb_conf.sh"]

# Lancer MariaDB en mode "serveur"
CMD ["mysqld", "--bind-address=0.0.0.0"]

