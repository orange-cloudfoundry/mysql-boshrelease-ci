#!/usr/bin/env bash 
set -eu

################################################################
# object : Identify cf-mysql-release version
#################################################################
# method : git tag 
#################################################################

#### Initialization

### Master cf-mysql
pushd cf-mysql-release
VERSION=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}' | tail -1)

### Master cf-mysql-deployment
popd
pushd cf-mysql-deployment 
VERSIONDEPL=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}' | tail -1)


### result
if [ ${VERSIONDEPL} == ${VERSION} ]
then 
  ### body of mail
  popd
  echo "New Release cf-mysql-release : ${VERSION} in progress ..." > output/mail.body
  
  ### update keyval
  cd version-release-mysql
  echo ${VERSION} >> keyval.properties

  echo "----------------------------------------------------------------------------------"
  echo "-- New Release cf-mysql-release : ${VERSION} " 
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### Error : "
  echo "###  . cf-mysql : ${VERSION} "
  echo "###  . cf-mysql-deployment : ${VERSIONDEPL} "
  echo "##################################################################################"
  exit 666
fi