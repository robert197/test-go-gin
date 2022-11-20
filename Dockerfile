FROM golang:1.18.3-stretch AS base

ARG ARCH=amd64

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=${ARCH}

ENV PATH /go/bin/linux_amd64/:$PATH

WORKDIR /app

COPY ./go.mod .
COPY ./go.sum .

RUN go mod download
RUN go mod verify

COPY . .

FROM golang:1.18.3-alpine as build

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

WORKDIR /build

RUN apk add -U --no-cache ca-certificates

COPY --from=base /app /build

RUN mkdir bin
RUN go build -o bin -mod mod ./...

FROM alpine:3.16

COPY --from=build /build/bin /
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

RUN apk update

ENTRYPOINT ["/test-go-gin", "run"]

