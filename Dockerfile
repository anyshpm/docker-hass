FROM homeassistant/home-assistant:2023.3.5

MAINTAINER Anyshpm Chen<anyshpm@anyshpm.com>

RUN echo 'https://mirrors.ustc.edu.cn/alpine/v3.16/main' > /etc/apk/repositories
RUN echo 'https://mirrors.ustc.edu.cn/alpine/v3.16/community' >> /etc/apk/repositories

COPY request.diff /tmp

RUN set -x && \
    apk add --no-cache patch && \
    cd /usr/local/lib/python3.*/site-packages/telegram/utils/ && \
    patch request.py < /tmp/request.diff && \
    rm -f /tmp/request.diff && \
    apk del patch
