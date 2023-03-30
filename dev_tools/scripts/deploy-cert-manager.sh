#!/bin/bash
set -x

helm repo add jetstack https://charts.jetstack.io
helm repo update

if ! kubectl get crd -A | grep certificaterequests.cert-manager.io; then
    helm install \
    cert-manager jetstack/ cert-manager \
    --version v1.7.1 \
    --set installCRDs=true
fi

if [ -z "$1" ]
  then
    kubectl apply -f ../config/cert-issuer.yaml
  else
    kubectl apply -f ../config/cert-issuer.yaml -n $1
fi
