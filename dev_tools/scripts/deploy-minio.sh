#!/bin/bash
set -x

helm repo add minio https://helm.min.io/
helm repo update

MINIO_ACCESS=$(grep s3_access_key sda-deploy-init/config/trace.yml | awk '{print $2}' | sed -e 's/\"//g')
MINIO_SECRET=$(grep s3_secret_key sda-deploy-init/config/trace.yml | awk '{print $2}' | sed -e 's/\"//g')

if [ "$1" = "issuer" ]; then
    kubectl apply -f ../config/minio-issuer.yaml -n ega-ns
    helm upgrade --install minio minio/minio --set accessKey="$MINIO_ACCESS",secretKey="$MINIO_SECRET",tls.enabled=true,tls.certSecret=minio-certs,tls.publicCrt=tls.crt,tls.privateKey=tls.key,persistence.enabled=true,persistence.storageClass=nfs-csi,service.port=443,ingress.enabled=true,ingress.hosts[0]="mega.dyn.cloud.e-infra.cz",ingress.tls[0].hosts[0]="mega.dyn.cloud.e-infra.cz",ingress.tls[0].secretName="mega-dyn-cloud-e-infra-cz-tls" \
    --set-string ingress.annotations.'nginx\.ingress\.kubernetes\.io\/backend-protocol'=HTTPS \
    --set-string ingress.annotations.'cert-manager\.io\/cluster-issuer'=letsencrypt-prod \
    --set-string ingress.annotations.'kubernetes\.io\/ingress\.class'=nginx \
    --set-string ingress.annotations.'kubernetes\.io\/tls-acme'="true" \
    --version 8.0.8 -n ega-ns

    #helm install minio minio/minio \
    #    --set accessKey="$MINIO_ACCESS",secretKey="$MINIO_SECRET",tls.enabled=true,tls.certSecret=minio-certs,tls.publicCrt=tls.crt,tls.privateKey=tls.key,persistence.enabled=false,service.port=443 --version 8.0.8
else
    kubectl create secret generic minio-certs --from-file=sda-deploy-init/config/certs/public.crt --from-file=sda-deploy-init/config/certs/private.key

    helm install minio minio/minio \
        --set accessKey="$MINIO_ACCESS",secretKey="$MINIO_SECRET",tls.enabled=true,tls.certSecret=minio-certs,persistence.enabled=false,service.port=443 --version 8.0.8
fi
