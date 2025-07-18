FROM node:lts

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG INTERNXT_CLI_VERSION

LABEL maintainer="Stefan Ruepp"
LABEL github="https://github.com/ruepp-jenkins/docker-internxt-cli"
LABEL INTERNXT_CLI_VERSION=${INTERNXT_CLI_VERSION}

ENV TZ=Europe/Berlin
ENV INTERNXT_USERNAME
ENV INTERNXT_PASSWORD
ENV INTERNXT_SECRET

ADD scripts/dockerfile/ /build

RUN /bin/bash /build/build.sh

EXPOSE 3005

VOLUME [ "/config" ]
CMD [ "/usr/local/bin/internxt" ]
