#!/bin/bash
set -x
openssl req \
    -newkey rsa:2048 \
    -x509 \
    -nodes \
    -keyout /saltyrtc/certs/saltyrtc.key \
    -new \
    -out /saltyrtc/certs/saltyrtc.crt \
    -subj /CN=localhost \
    -reqexts SAN \
    -extensions SAN \
    -config <(cat /etc/ssl/openssl.cnf \
        <(printf '[SAN]\nsubjectAltName=DNS:localhost')) \
    -sha256 \
    -days 3
openssl x509 -in /saltyrtc/certs/saltyrtc.crt -outform der -out /saltyrtc/certs/saltyrtc.der
