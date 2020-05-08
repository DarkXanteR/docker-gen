ARG GO_VERSION=alpine
ARG DIST=alpine
ARG DIST_VERSION=latest

FROM golang:${GO_VERSION} AS builder

ARG VERSION=0.7.4
ARG ARCHITECTURE=amd64

ENV DOCKER_HOST unix:///tmp/docker.sock

RUN apk -U add openssl make git gcc libc-dev

WORKDIR /src
COPY . .

RUN make get-deps
RUN make all check-gofmt test

ARG DIST
ARG DIST_VERSION
FROM ${DIST}:${DIST_VERSION}

COPY --from=0 /src/docker-gen /usr/local/bin
COPY --from=0 /src/templates /var/docker-gen/templates
COPY --from=0 /src/examples /var/docker-gen/examples

RUN chmod 644 /usr/local/bin
RUN chmod -R 644 /var/docker-gen/

ENTRYPOINT ["/usr/local/bin/docker-gen"]
