FROM golang:1.9-alpine

# Terraform

ENV TERRAFORM_VERSION=0.11.8

RUN apk update && \
    apk add bash ca-certificates git openssl unzip wget && \
    cd /tmp && \
    wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    rm -rf /tmp/* && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/tmp/*

# Dep

RUN wget -O - https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

WORKDIR /go/src/app
