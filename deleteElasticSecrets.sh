#Used for deleting certificates
NAMESPACE=default
kubectl -n $NAMESPACE delete secret elastic-certificates && \
kubectl -n $NAMESPACE delete secret elastic-certificate-pem && \
kubectl -n $NAMESPACE delete secret elastic-certificate-crt && \
kubectl -n $NAMESPACE delete secret elastic-credentials && \
