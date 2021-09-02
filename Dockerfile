FROM mafio69/debian:start

ENV SUPERCRONIC_URL=https://github.com/aptible/supercronic/releases/download/v0.1.12/supercronic-linux-amd64 \
    SUPERCRONIC=supercronic-linux-amd64 \
    SUPERCRONIC_SHA1SUM=048b95b48b708983effb2e5c935a1ef8483d9e3e

RUN wget https://get.symfony.com/cli/installer -O - | bash

RUN curl -fsSLO "$SUPERCRONIC_URL" \
    && echo "${SUPERCRONIC_SHA1SUM}  ${SUPERCRONIC}" | sha1sum -c - \
    && chmod +x "$SUPERCRONIC" \
    && mv "$SUPERCRONIC" "/usr/local/bin/${SUPERCRONIC}" \
    && ln -s "/usr/local/bin/${SUPERCRONIC}" /usr/local/bin/supercronic \
    && curl -sS https://getcomposer.org/installer | php \
    && mkdir -p /usr/share/nginx/logs/ \
    && touch -c /usr/share/nginx/logs/error.log \
    && mkdir -p /usr/share/nginx/logs/ \
    && cp composer.phar /usr/local/bin/composer  \
    && mv composer.phar /usr/bin/composer \
    && mv  /root/.symfony/bin/symfony /usr/local/bin/symfony \
    && ln -sf /var/log/nginx/project_access.log \
    && ln -sf /var/log/nginx/project_error.log \
    && ln -sf /usr/share/nginx/logs/access.log \
    && ln -sf /usr/share/nginx/logs/error.log \
    && addgroup docker

COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/mime.types /etc/nginx/mime.types
COPY config/php.ini /usr/local/etc/php/conf.d/php.ini
COPY config/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY ./main /main
COPY config/cron-task /etc/cron.d/crontask
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/enabled-symfony.conf /etc/nginx/conf.d/enabled-symfony.conf

RUN usermod -a -G docker root && adduser \
       --system \
       --shell /bin/bash \
       --disabled-password \
       --home /home/docker \
       docker \
       && apt update \
       && apt install -y supervisor \
       && usermod -a -G docker root \
       && usermod -a -G docker docker \
       && chown -R docker:docker /var/log

ADD --chown=docker:docker /main /main
STOPSIGNAL SIGQUIT
WORKDIR /
EXPOSE 8080 9000
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
STOPSIGNAL SIGQUIT
#CMD ["php-fpm"]
CMD ["/usr/bin/supervisord", "-nc", "/etc/supervisor/conf.d/supervisord.conf"]
