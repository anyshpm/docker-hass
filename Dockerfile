FROM homeassistant/home-assistant:2024.4.1

MAINTAINER Anyshpm Chen<anyshpm@anyshpm.com>

COPY _httpxrequest.diff /tmp

RUN set -x && \
    apk add --no-cache patch && \
    cd /usr/local/lib/python3.*/site-packages/telegram/request/ && \
    patch _httpxrequest.py < /tmp/_httpxrequest.diff && \
    rm -f /tmp/_httpxrequest.diff && \
    apk del patch
