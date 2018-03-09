#!/usr/bin/env bash 
set -e

################################################################
# object : validate deployment of cf-mysql
#################################################################
# method : excecute smoke-test : 
#          by default it's Standalone smoke test 
#            . cf_mysql.mysql.standalone_tests_only: true in cf-mysql-deployment
#################################################################
# type :
#           - create table 
#           - insert
#           - select
################################################################

#### Initialization 
export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

#### execute test
bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} run-errand smoke-tests-vm

if [ $? = 0 ]
then 
  echo "----------------------------------------------------------------------------------"
  echo "-- Run smoke-test on cf-mysql-release : OK" 
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### Error to smoke-test on cf-mysql-release"
  echo "##################################################################################"
fi
