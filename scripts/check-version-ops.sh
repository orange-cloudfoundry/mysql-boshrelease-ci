#!/usr/bin/env sh
set -ex

################################################################
# object : Identify 
#################################################################
#################################################################

#### Initialization

### 
cd prometheus-version
VERSION_PROMETHEUS=$(cat metadata|jq -r '.version.ref') 
cd ..

### 
cd shield-version
VERSION_SHIELD=$(cat metadata|jq -r '.version.ref') 
cd ..

### body of mail
echo "New Release cf-mysql-release : in progress ...Prometheus (${VERSION_PROMETHEUS}) and Shield (${VERSION_SHIELD}) " > output/mail.body

### update keyval
cd bosh-version-ops
echo "Prometheus (${VERSION_PROMETHEUS}) and Shield (${VERSION_SHIELD}) " >> keyval.properties

