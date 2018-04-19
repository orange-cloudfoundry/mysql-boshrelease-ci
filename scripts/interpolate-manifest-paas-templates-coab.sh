#!/usr/bin/env bash 
set -eu

################################################################
# object : interpolate paas-templates coab of cf-mysql
################################################################
# method : bosh interpolate -d <deployment name>
################################################################

#### Initialization
operations=""
export dirtemplaterelease="./git-paas-templates-coab/${REP_TEMPLATE}/${NAME_TEMPLATE_RELEASE}/template"
export dirtemplate="./git-paas-templates-coab/${REP_TEMPLATE}"

echo "----------------------------------------------------------------------------------"
echo "-- Interpolate paas-templates"
echo "----------------------------------------------------------------------------------"


##############################################################################################
#### redifinitation link
##############################################################################################
rmdir ${dirtemplaterelease}/cf-mysql-deployment
ln -f -s $(readlink -f cf-mysql-deployment) ${dirtemplaterelease}/cf-mysql-deployment

##############################################################################################
#### verification version
##############################################################################################
pushd ${dirtemplaterelease}/cf-mysql-deployment
VERSIONSUB=$(git tag | xargs -I@ git log --format=format:"%ai @%n" -1 @ | sort | awk '{print $4}' | tail -1)
popd
VERSIONREL=$(grep -w 'cf-mysql-version' ${dirtemplate}/coab-depls-versions.yml | awk '{printf("v%s\n",$2)}' | sed 's/"//g')
# en attendant un merge 
#pushd ${dirtemplaterelease}/cf-mysql-release
# VERSIONREL=v36.16.0
#git checkout tags/${VERSIONREL}
#popd

### verfication version
if [ ${VERSIONSUB} == ${VERSIONREL} ]
then 
  echo "----------------------------------------------------------------------------------"
  echo " version submodule cf-mysql-deployment :" ${VERSIONSUB}
  echo " version template cf-mysql-release     :" ${VERSIONREL}
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### Error : "
  echo "###  . version submodule cf-mysql-deployment :" ${VERSIONSUB}
  echo "###  . version template cf-mysql-release     :" ${VERSIONREL}
  echo "##################################################################################"
  exit 666
fi


##############################################################################################
#### operations definition 
##############################################################################################
# define ops with all file except cf-mysql-tpl.yml
# manifest de la release
manifest=${dirtemplaterelease}/${NAME_TEMPLATE_RELEASE}.yml

# liste des operations
operations=$(ls ${dirtemplaterelease}/*operators.yml | awk '{printf(" -o %s\n",$0)}')
#varsfiles=${dirtemplaterelease}/${NAME_TEMPLATE_RELEASE}-vars.yml

# recopie du plan small
cp ${dirtemplaterelease}/${NAME_TEMPLATE_RELEASE}-vars_plan-coab-mariadb-small.yml ${dirtemplaterelease}/${NAME_TEMPLATE_RELEASE}-vars.yml

#liste des cars
varsfile=$(ls ${dirtemplaterelease}/*vars.yml | awk '{printf(" -l %s\n",$0)}')

echo "----------------------------------------------------------------------------------"
echo "Manifest :"
echo ${manifest}
echo "----------------------------------------------------------------------------------"
echo "Operations :"
echo ${operations} | sed 's/-o ./\n -o ./g'
echo "----------------------------------------------------------------------------------"
echo "varsfile :"
echo ${varsfile} | sed 's/-l ./\n -l ./g'
echo "----------------------------------------------------------------------------------"

##############################################################################################
#### interpolate
##############################################################################################
bosh -d ${DEPLOYMENT_NAME} interpolate \
  ${manifest}\
  ${operations} \
  ${varsfile} \
  > ./manifest-with-variables.yml

if [ $? = 0 ]
then 
  bosh -d ${DEPLOYMENT_NAME} interpolate \
    ${manifest} \
    ${operations} \
    ${varsfile} \
    > "${OUTPUT_FILE}"

  #### affichage du resultat
  echo "----------------------------------------------------------------------------------"
  cat  ${OUTPUT_FILE}
  
  echo "----------------------------------------------------------------------------------"
  echo "-- interpolate paas-templates :  OK"
  echo "----------------------------------------------------------------------------------"
else
  echo "##################################################################################"
  echo "### interpolate paas-templates :  KO"  
  echo "### Error to identify cf-mysql-release version"
  echo "##################################################################################"
fi