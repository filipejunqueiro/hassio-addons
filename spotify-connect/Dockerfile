ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y jq sox alsa-utils curl && \
    rm -rf /var/lib/apt/lists/*

# Install Raspotify (librespot wrapper)
RUN curl -sL https://dtcooper.github.io/raspotify/install.sh | sh

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
