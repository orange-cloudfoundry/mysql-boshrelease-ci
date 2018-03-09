#!/usr/bin/env bash 
set -e

################################################################
# object : Identify cf-mysql-release version
#################################################################
# method : git tag 
#################################################################

#### Initialization

### Master
pushd cf-mysql-release
VERSION=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}' | tail -1)

### result
if [ $? = 0 ]
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
  echo "### Error to identify cf-mysql-release version"
  echo "##################################################################################"
fi