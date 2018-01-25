FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
&& apt-get install --no-install-suggests -y apache2 libapache2-mod-security2 modsecurity-crs \
&& a2dismod status mpm_event \
&& a2enmod mpm_prefork authnz_ldap ldap proxy proxy_html proxy_http proxy_http2 proxy_wstunnel rewrite sed ssl expires headers http2 substitute slotmem_shm \
&& a2dissite 000-default \
&& apt-get clean ; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/* /usr/share/doc/*

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

# logs should go to stdout / stderr
RUN . "$APACHE_ENVVARS" \
&& ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log" \
&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log" \
&& ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log" \
&& echo 'export APACHE_MYIP=$(hostname -i)' >> "$APACHE_CONFDIR/envvars" \
&& echo 'export APACHE_MYFQDN=$(hostname -f)' >> "$APACHE_CONFDIR/envvars"


# chmod +x apache2-foreground docker-entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin/

COPY apache2-foreground /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

WORKDIR /var/www/html

EXPOSE 80

CMD ["apache2-foreground"]

