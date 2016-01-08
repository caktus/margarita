#!/bin/bash
# Generates a new self-signed cert for the given domain
# Ex: ./generate-cert.sh example.com
openssl genrsa -out $1.key 2048
cp $1.key $1.key.secure
openssl rsa -in $1.key.secure -out $1.key
openssl req -new -key $1.key -subj "/C=US/ST=North Carolina/L=Carborro/O=Salt Stack/OU=IT/CN=$1" -out $1.csr
openssl x509 -req -days 365 -in $1.csr -signkey $1.key -out $1.crt