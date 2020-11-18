#remember to set domain towards ip-address before trying to install cert-manager
#Always run a test towards the staging enviroment first
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.1/cert-manager-legacy.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v0.15.2 --set installCRDs=true
kubectl get pods --namespace cert-manager