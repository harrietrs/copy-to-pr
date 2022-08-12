FROM golang:1.15-alpine3.13

RUN apk update && \
    apk upgrade && \
    apk add build-base && \
    apk add git 

ADD entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
