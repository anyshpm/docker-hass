FROM homeassistant/home-assistant:2025.2.3

LABEL maintainer="Anyshpm Chen <anyshpm@anyshpm.com>" \
      org.opencontainers.image.description="Home Assistant with telegram patch"

COPY _httpxrequest.diff /tmp/

RUN set -x \
    && apk add --no-cache --virtual .build-deps patch \
    && cd /usr/local/lib/python3.*/site-packages/telegram/request/ \
    && patch _httpxrequest.py < /tmp/_httpxrequest.diff \
    && rm -f /tmp/_httpxrequest.diff \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* \
    && :
