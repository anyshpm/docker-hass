FROM homeassistant/home-assistant:2023.5.4

MAINTAINER Anyshpm Chen<anyshpm@anyshpm.com>

COPY request.diff /tmp

RUN set -x && \
    apk add --no-cache patch && \
    cd /usr/local/lib/python3.*/site-packages/telegram/utils/ && \
    patch request.py < /tmp/request.diff && \
    rm -f /tmp/request.diff && \
    apk del patch
