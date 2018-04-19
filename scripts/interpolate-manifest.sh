#!/usr/bin/env bash 
set -eu

################################################################
# object    : interpolate of cf-mysql
################################################################
# method    : bosh interpolate -d <deployment name>
################################################################
# parameter : DEPLOYMENT_NAME 
#             ARBITRATOR
#             SYSLOG
#             PROMETHEUS
#             SHIELD
#             TYPE_OS
################################################################

#### Initialization
operations=""

echo "----------------------------------------------------------------------------------"
echo "-- Interpolate"
echo "----------------------------------------------------------------------------------"

##############################################################################################
#### operations definition 
##############################################################################################
if ${ARBITRATOR}
then
  echo "--> without Arbitrator"
  operations="$operations -o ./cf-mysql-deployment/operations/no-arbitrator.yml"
else 
  echo "--> with Arbitrator"
  operations="$operations -o ./mysql-boshrelease-ci/operations/customize_arbitrator.yml"
fi

if ${PROMETHEUS}
then
  echo "--> with Promtheus"
  operations="$operations -o ./mysql-boshrelease-ci/operations/customize_prometheus.yml"
fi

if ${SHIELD}
then
  echo "--> with Shield"
  operations="$operations -o ./mysql-boshrelease-ci/operations/customize_shield_v7.yml"
fi

##############################################################################################
#### interpolate
##############################################################################################
bosh -d ${DEPLOYMENT_NAME} interpolate \
    ./cf-mysql-deployment/cf-mysql-deployment.yml \
    ${operations} \
    -o ./mysql-boshrelease-ci/operations/customize_deployment_mysql.yml \
    -o ./mysql-boshrelease-ci/operations/customize_mariadb.yml \
    -l ./cf-mysql-deployment/bosh-lite/default-vars.yml \
    -v type_os=$TYPE_OS \
    --vars-store ./mysql-boshrelease-ci/operations/credentials.yml  \
        > ./manifest-with-variables.yml

if [ $? = 0 ]
then 
  bosh interpolate -d ${DEPLOYMENT_NAME} \
      ./manifest-with-variables.yml \
      -o ./mysql-boshrelease-ci/operations/remove-variables.yml \
      > "${OUTPUT_FILE}"

  #### affichage du resultat
  echo "----------------------------------------------------------------------------------"
  cat  ${OUTPUT_FILE}
  
  echo "----------------------------------------------------------------------------------"
  echo "-- interpolate :  OK"
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### Error to identify cf-mysql-release version"
  echo "##################################################################################"
fi