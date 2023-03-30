#!/bin/bash
set -x

basedir="sda-deploy-init/config"

export LC_ALL=C
if ! [ -d "$basedir" ]; then
  mkdir -p "${basedir}"
fi


DB_IN=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
DB_OUT=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

S3_Access=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
S3_Secret=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

G4GH=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

touch "${basedir}/trace.yml"

G4GH="${G4GH}" DB_IN="${DB_IN}" DB_OUT="${DB_OUT}" S3_Access="${S3_Access}" S3_Secret="${S3_Secret}" \
yq e -i '
  .secrets.c4gh_passphrase = strenv(G4GH) |
  .secrets.pg_in_password = strenv(DB_IN) |
  .secrets.pg_out_password = strenv(DB_OUT) |
  .secrets.s3_access_key = strenv(S3_Access) |
  .secrets.s3_secret_key = strenv(S3_Secret) 
' "${basedir}/trace.yml"

crypt4gh generate -n "${basedir}/c4gh" -p "$G4GH"

if [ -z "$1" ]
  then
      kubectl create secret generic c4gh --from-file="${basedir}/c4gh.sec.pem" --from-file="${basedir}/c4gh.pub.pem" --from-literal=passphrase="${G4GH}"
  else
      kubectl create secret generic c4gh --from-file="${basedir}/c4gh.sec.pem" --from-file="${basedir}/c4gh.pub.pem" --from-literal=passphrase="${G4GH}" -n $1
fi

# secret for the OIDC keypair
openssl ecparam -name prime256v1 -genkey -noout -out "${basedir}/jwt.key"
openssl ec -in "${basedir}/jwt.key" -pubout -out "${basedir}/jwt.pub"

if [ -z "$1" ]
  then
      kubectl create secret generic oidc --from-file="${basedir}/jwt.key" --from-file="${basedir}/jwt.pub"
  else
      kubectl create secret generic oidc --from-file="${basedir}/jwt.key" --from-file="${basedir}/jwt.pub" -n $1
fi

