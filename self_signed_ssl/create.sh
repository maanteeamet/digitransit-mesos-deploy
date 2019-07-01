#!/bin/bash


if [ -z "$1" ]; then
	echo "Usage: creat.sh <FQDN>"
	echo "Must cpecify FQDN as a parameter"
	exit 1;
fi

FQDN=`basename $1`

if [ -z "$FQDN" ]; then
	echo "Must cpecify FQDN as a parameter"
	exit 1
fi

if [ -f "$FQDN.key" ]; then
	echo "$FQDN.key already exists. Remove or rename it beore trying again"
	exit 1
fi


echo "Creating ${FQDN} self-signed key";

openssl genrsa -out ${FQDN}.key 1024
openssl req -new -key ${FQDN}.key -out ${FQDN}.csr
openssl x509 -req -days 365 -in ${FQDN}.csr -signkey ${FQDN}.key -out ${FQDN}.crt
openssl pkcs12 -export -out ${FQDN}.pfx -inkey ${FQDN}.key -in ${FQDN}.crt

