#!/bin/bash
set -e

if [ "$1" = "federated" ]; then
    CEGA_MQ_PASS=$(grep cega_mq_pass sda-deploy-init/config/trace.yml | awk '{print $2}' | sed -e 's/\"//g')
fi

HASH="DI0kJIvQHptGSBH2coZ25dsjjN9Z4uxp8hAyqtd9H7rb/SBO"

if [ -f "sda-deploy-init/config/certs/ca.crt" ]; then
    ## sda-mq certs
    kubectl create secret generic mq-certs \
        --from-file=sda-deploy-init/config/certs/ca.crt \
        --from-file=sda-deploy-init/config/certs/server.crt \
        --from-file=sda-deploy-init/config/certs/server.key

    kubectl create secret generic mq-tester-certs \
        --from-file=sda-deploy-init/config/certs/ca.crt \
        --from-file=sda-deploy-init/config/certs/tester.crt \
        --from-file=sda-deploy-init/config/certs/tester.key

    helm install broker charts/sda-mq \
        --set securityPolicy.create=false,global.adminUser=admin,global.adminPasswordHash="$HASH",global.shovel.host=cega-mq,global.shovel.user=lega,global.shovel.pass="$CEGA_MQ_PASS",global.shovel.vhost=lega,global.vhost=sda,global.tls.secretName=mq-certs,global.tls.keyName=server.key,global.tls.certName=server.crt,global.tls.caCert=ca.crt,global.tls.verifyPeer=true,testimage.tls.secretName=mq-tester-certs,testimage.tls.tlsKey=tester.key,testimage.tls.tlsCert=tester.crt,testimage.tls.caCert=ca.crt
else
    helm install broker charts/sda-mq \
        --set securityPolicy.create=false,global.adminUser=admin,global.adminPasswordHash="$HASH",global.shovel.host=cega-mq,global.shovel.user=lega,global.shovel.pass="$CEGA_MQ_PASS",global.shovel.vhost=lega,global.vhost=sda,global.tls.secretName=mq-certs,global.tls.serverKey=server.key,global.tls.serverCert=server.crt,global.tls.caCert=ca.crt,global.tls.verifyPeer=true,testimage.tls.secretName=mq-certs,testimage.tls.tlsKey=tls.key,testimage.tls.tlsCert=tls.crt,testimage.tls.caCert=ca.crt
fi
