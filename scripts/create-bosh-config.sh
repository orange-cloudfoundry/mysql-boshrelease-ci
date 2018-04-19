#!/usr/bin/env bash 
set -eu

################################################################
# object    : define bosh config for bosh-cli : bosh_config.yml
################################################################
# method    : bosh delete-deployment 
#             bosh delete-disk
################################################################
# parameter : CA_CERT:  
#             IP
#             ALIAS
#             USER
#             PASSWORD
################################################################

#### environnement bosh
mkdir -p bosh-director-config
cd bosh-director-config || exit 115

# retrieving certificate provided by pipeline
cat > ./bosh_ca.crt <<EOF
$CA_CERT
EOF

export BOSH_CONFIG=$PWD/bosh_config.yml

bosh -e $IP alias-env $ALIAS --ca-cert=./bosh_ca.crt
( echo $USER ; echo $PASSWORD ) \
    | bosh -e $ALIAS log-in

if [ $? = 0 ]
then 
  echo "----------------------------------------------------------------------------------"
  echo "-- Connection BOSH : OK" 
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### Connection BOSH : KO"
  echo "##################################################################################"
fi  