#!/usr/bin/env bash 
set -eu

################################################################
# object : interpolate paas-templates ops of cf-mysql
################################################################
# method : bosh interpolate -d <deployment name>
################################################################

#### Initialization
operations=""
export dirtemplaterelease="./git-paas-templates-ops/${REP_TEMPLATE}/${NAME_TEMPLATE_RELEASE}/template"
export dirtemplate="./git-paas-templates-ops/${REP_TEMPLATE}"

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
##VERSIONSUB=v36
git checkout tags/${VERSIONSUB}
popd
VERSIONREL=$(grep -w 'cf-mysql-version' ${dirtemplate}/ops-depls-versions.yml | awk '{printf("v%s\n",$2)}' | sed 's/"//g')



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
manifest=${dirtemplaterelease}/${NAME_TEMPLATE_RELEASE}.yml
operations=$(ls ${dirtemplaterelease}/*.yml | grep -v ${NAME_TEMPLATE_RELEASE}-vars-tpl.yml | grep -v ${NAME_TEMPLATE_RELEASE}.yml| awk '{printf(" -o %s\n",$0)}')
varsfile=${dirtemplaterelease}/${NAME_TEMPLATE_RELEASE}-vars-tpl.yml

echo "----------------------------------------------------------------------------------"
echo "Manifest :"
echo ${manifest}
echo "----------------------------------------------------------------------------------"
echo "Operations :"
echo ${operations} | sed 's/-o ./\n -o ./g'
echo "----------------------------------------------------------------------------------"
echo "varsfile :"
echo ${varsfile}
echo "----------------------------------------------------------------------------------"

##############################################################################################
#### interpolate
##############################################################################################
bosh -d ${DEPLOYMENT_NAME} interpolate \
  ${manifest}\
  ${operations} \
  --vars-file ${varsfile} \
  > ./manifest-with-variables.yml

if [ $? = 0 ]
then 
  bosh -d ${DEPLOYMENT_NAME} interpolate \
    ${manifest}\
    ${operations} \
      -o ./mysql-boshrelease-ci/operations/remove-variables.yml \
      --vars-file ${varsfile} \
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