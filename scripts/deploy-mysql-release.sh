#!/usr/bin/env bash 
set -eu

################################################################
# object : deploy of cf-mysql
################################################################
# method : bosh create release
#          bosh upload release 
#          bosh deploy -d <deployment name>
################################################################

#### Initialization
#export ROOT_FOLDER=${PWD}
export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

operations=""

echo "----------------------------------------------------------------------------------"
echo "-- Deployment $VERSION_RELEASE "
echo "----------------------------------------------------------------------------------"

##############################################################################################
#### operations  
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
### For cf-mysql-deployment
##############################################################################################
pushd cf-mysql-deployment

if [ $VERSION_RELEASE = "PREVIOUS" ]
then
  ### checkout previous release
  VERSION=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}' | tail -2 | sort -r | tail -1)
  git checkout tags/${VERSION}
fi

### renaming release
sed -i -e "s/\(^.*[[:space:]]*\)cf-mysql\([[:space:]$,]*\)/\1${RELEASE_NAME}\2/g" cf-mysql-deployment.yml

popd

##############################################################################################
### For cf-mysql-release
##############################################################################################
pushd cf-mysql-release

### Version master
VERSION=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}' | tail -1)

if [ $VERSION_RELEASE = "PREVIOUS" ]
then
  VERSION=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}' | tail -2 | sort -r | tail -1)
  ### checkout previous release
  git checkout tags/${VERSION}
fi

### renaming release
_VERSION=$(echo $VERSION|sed -e 's/^v//')
sed -i -e "s/final_name:[[:space:]]*cf-mysql/final_name: ${RELEASE_NAME}/" ./config/final.yml

mkdir -p ${PWD}/releases/${RELEASE_NAME}
cp ${PWD}/releases/cf-mysql/*${_VERSION}.yml ${PWD}/releases/${RELEASE_NAME}/${RELEASE_NAME}-${_VERSION}.yml

sed -i -e "s/\(^name.*[[:space:]]*\)cf-mysql[[:space:]$]*/\1${RELEASE_NAME}/" \
            ${PWD}/releases/${RELEASE_NAME}/${RELEASE_NAME}-${_VERSION}.yml
popd

##############################################################################################
#### create release cf-mysql
##############################################################################################
pushd cf-mysql-release

./scripts/update
if [ $? = 0 ]
then 
  echo "----------------------------------------------------------------------------------"
  echo "-- ./scripts/update : OK"
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### ./scripts/update : KO"
  echo "##################################################################################"
fi

bosh -e ${ALIAS} create-release --force
if [ $? = 0 ]
then 
  echo "----------------------------------------------------------------------------------"
  echo "-- create-release : OK"
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### create-release : KO"
  echo "##################################################################################"
fi

bosh -e ${ALIAS} upload-release --version=${_VERSION}
if [ $? = 0 ]
then 
  echo "----------------------------------------------------------------------------------"
  echo "-- upload-release : OK"
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### upload-release : KO"
  echo "##################################################################################"
fi

popd

##############################################################################################
### Deployment
##############################################################################################
bosh -e ${ALIAS} -n -d ${DEPLOYMENT_NAME} deploy \
    ./cf-mysql-deployment/cf-mysql-deployment.yml \
    ${operations} \
    -o ./mysql-boshrelease-ci/operations/customize_deployment_mysql.yml \
    -o ./mysql-boshrelease-ci/operations/customize_mariadb.yml \
    -l ./cf-mysql-deployment/bosh-lite/default-vars.yml \
    -v type_os=$TYPE_OS \
    --vars-store ./mysql-boshrelease-ci/operations/credentials.yml 

if [ $? = 0 ]
then 
  echo "----------------------------------------------------------------------------------"
  echo "-- deploy cf-mysql-deployment : OK"
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### deploy cf-mysql-deployment : KO"
  echo "##################################################################################"
fi