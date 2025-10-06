# Base image
FROM debian:bookworm

# Installer Nginx et OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Créer le dossier SSL et générer un certificat auto-signé
RUN mkdir -p /etc/nginx/ssl \
 && openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=MO/ST=KH/L=KH/O=1337/OU=1337/CN=gchauvot.42.fr/UID=gchauvotb"

# Copier la configuration Nginx personnalisée
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Créer le dossier WordPress et définir les permissions
RUN mkdir -p /var/www/html \
 && chown -R www-data:www-data /var/www/html


EXPOSE 443

# Lancer Nginx au premier plan
CMD ["nginx", "-g", "daemon off;"]
