#!/bin/bash
# Usage: STACK_VERSION=7.8.0 DNS_NAME=elasticsearch NAMESPACE=default ./create-elastic-certificates.sh
STACK_VERSION=7.8.0
DNS_NAME=elasticsearch-master
NAMESPACE=default
pw=changeme
# ELASTICSEARCH
#Check if an elastic-helm-charts-certs container is running
#docker rm -f elastic-helm-charts-certs || true
#Check that no certificates exists in current folder
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12 || true
#generate a password for the elastic account
password=$([ ! -z "$ELASTIC_PASSWORD" ] && echo $ELASTIC_PASSWORD || echo $(docker run --rm docker.elastic.co/elasticsearch/elasticsearch:$STACK_VERSION /bin/sh -c "< /dev/urandom tr -cd '[:alnum:]' | head -c20")) && \
#echo "Password for the elastic account" $password
#Generate CA certificate using the elasticsearch-certutil in an elasticsearch container
docker run --name elastic-helm-charts-certs --env DNS_NAME -i -w /app \
        docker.elastic.co/elasticsearch/elasticsearch:$STACK_VERSION \
        /bin/sh -c " \
                elasticsearch-certutil ca --out /app/elastic-stack-ca.p12 --pass '' && \
                elasticsearch-certutil cert --name $DNS_NAME --dns $DNS_NAME --ca /app/elastic-stack-ca.p12 --pass '' --ca-pass '' --out /app/elastic-certificates.p12" && \
#copy the certificates to host machine
docker cp elastic-helm-charts-certs:/app/elastic-certificates.p12 ./ && \
#Remove eleastic docker container
docker rm -f elastic-helm-charts-certs && \
#generate pem-file
openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -out elastic-certificate.pem  && \
#generate crt-file
openssl pkcs12 -nodes -passin pass:'' -in elastic-certificates.p12 -clcerts -nokeys -chain -out elastic-certificate.crt && \
#store the certs as kubernetes secrets
kubectl -n $NAMESPACE create secret generic elastic-certificates --from-file=elastic-certificates.p12 && \
kubectl -n $NAMESPACE create secret generic elastic-certificate-pem --from-file=elastic-certificate.pem && \
kubectl -n $NAMESPACE create secret generic elastic-certificate-crt --from-file=elastic-certificate.crt && \
rm -f elastic-certificates.p12 elastic-certificate.pem elastic-stack-ca.p12 elastic-certificate.crt && \
#
kubectl -n $NAMESPACE create secret generic elastic-credentials  --from-literal=password=$pw --from-literal=username=elastic # && \
