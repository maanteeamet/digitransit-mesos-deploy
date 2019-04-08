#!/bin/bash
openssl genrsa -out test.key 1024
openssl req -new -key test.key -out test.csr
openssl x509 -req -days 365 -in test.csr -signkey test.key -out test.crt
openssl pkcs12 -export -out test.pfx -inkey test.key -in test.crt
