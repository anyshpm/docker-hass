FROM homeassistant/home-assistant:2024.11.2

LABEL maintainer="Anyshpm Chen <anyshpm@anyshpm.com>"

COPY _httpxrequest.diff /tmp

RUN set -x && \
    apk add --no-cache --virtual .build-deps patch && \
    cd /usr/local/lib/python3.*/site-packages/telegram/request/ && \
    patch _httpxrequest.py < /tmp/_httpxrequest.diff && \
    rm -f /tmp/_httpxrequest.diff && \
    apk del .build-deps
