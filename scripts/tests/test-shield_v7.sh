#!/usr/bin/env sh
set -ex

################################################################
# object : validate backup mariadb via shield
#################################################################
# method : 
#################################################################
# type :
################################################################

#### Initialization 
export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

ROOT_FOLDER=${PWD}

### verify target into shield

### verify jobs into shield : 
# . xtrabackup-<deployement-name>-0
# . xtrabackup-<deployement-name>-1
# . xtrabackup-<deployement-name>-2
# . msqldump-cf-mysql-concourse-0
# . msqldump-cf-mysql-concourse-1
# . msqldump-cf-mysql-concourse-2

shield jobs xtrabackup-${DEPLOYMENT_NAME}-0
shield jobs myslqdump-${DEPLOYMENT_NAME}-0

shield run-job "xtrabackup-${DEPLOYMENT_NAME}-0" --yes
shield run-job "myslqdump-${DEPLOYMENT_NAME}-1" --yes


		
