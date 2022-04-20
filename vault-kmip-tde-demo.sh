#! /bin/bash

# downloading MongoDB
mkdir -p mongodb
mkdir -p mongodb_data
curl -o mongodb/mongodb.tgz https://downloads.mongodb.com/osx/mongodb-macos-x86_64-enterprise-5.0.6.tgz
tar -zxvf mongodb/mongodb.tgz --strip-components=1 -C mongodb

# assuming Vault Enterprise is already installed
# setting it up
VAULT_ADDR=http://127.0.0.1:8200
VAULT_TOKEN=root
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root

vault server -dev -dev-root-token-id=root &

sleep 5
vault secrets enable kmip
vault secrets list

# creates a CA and a server certificate
# (parameters for this certificate can be customised)
vault write kmip/config listen_addrs=0.0.0.0:5696
# CLICK ALLOW ON YOUR Mac

# vault read kmip/ca
vault read -format=json kmip/ca | jq -r .data.ca_pem > ca.pem

vault write -f kmip/scope/finance
vault list kmip/scope
vault write kmip/scope/finance/role/mongodb_tde operation_all=true
vault list kmip/scope/finance/role
vault read kmip/scope/finance/role/mongodb_tde

vault write -format=json kmip/scope/finance/role/mongodb_tde/credential/generate \
        cert_format=pem_bundle |jq -r .data.certificate > client.pem

mongodb/bin/mongod --dbpath ./mongodb_data --enableEncryption --kmipServerName localhost \
         --kmipPort 5696 --kmipServerCAFile ca.pem \
         --kmipClientCertificateFile client.pem

# search for KMIP and find
# STORAGE  [initandlisten] Created KMIP key with id: JOtEFmV7l8GjmrJFE2lo4TmxeEGNqtwb
# STORAGE  [initandlisten] Encryption key manager initialized using KMIP key with id: JOtEFmV7l8GjmrJFE2lo4TmxeEGNqtwb.


## to run again you'll need to remove the mongodb_data folder.
# rm -rf mongodb_data
# killall vault