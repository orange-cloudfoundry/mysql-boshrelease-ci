#!/usr/bin/env bash 
set -e

################################################################
# object : validate prometheus mysqld_exporter
#################################################################
# method : CURL mysqld_exporter 
#           . <host>:9104/metric 
#################################################################
# type   : find value of status MySQL : 
#            . wsrep_cluster_size
#################################################################
# result : 3 (even with arbitrator)
################################################################

#### Initialization 
#export ROOT_FOLDER=${PWD}
export BOSH_CONFIG=$PWD/bosh-director-config/bosh_config.yml

#### execute test
for i in $(bosh -e ${ALIAS} -d ${DEPLOYMENT_NAME} instances | grep mysql | awk '{printf ("%s\n", $NF) }')
do
  IP=$(echo $i)
  NB=$(curl -s 0 http://${IP}:9104/metrics | egrep -w -c "mysql_global_status_wsrep_cluster_size 3")
  if [ $NB -ne 1 ]
  then
    echo "----------------------------------------------------------------------------------"
    echo "-- Prometheus mysqld_exporter : KO" 
    echo "--> wrong value mysql status wsrep_cluster_size. "
    echo "----------------------------------------------------------------------------------"
   exit 1
  fi
done
echo "----------------------------------------------------------------------------------"
echo "-- Prometheus mysqld_exporter : OK" 
echo "----------------------------------------------------------------------------------"


