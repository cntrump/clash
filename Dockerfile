FROM golang:alpine as builder

RUN apk add --no-cache make git curl gcc g++
RUN curl -L https://github.com/Dreamacro/maxmind-geoip/releases/latest/download/Country.mmdb > /Country.mmdb
WORKDIR /clash-src
COPY --from=tonistiigi/xx:golang / /
COPY . /clash-src
RUN go mod download && \
    make docker && \
    mv ./bin/clash-docker /clash

FROM alpine:latest
LABEL org.opencontainers.image.source="https://github.com/Dreamacro/clash"

RUN apk add --no-cache ca-certificates
COPY --from=builder /Country.mmdb /root/.config/clash/
COPY --from=builder /clash /
ENTRYPOINT ["/clash"]
