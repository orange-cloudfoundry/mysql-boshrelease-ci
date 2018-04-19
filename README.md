# mysql-boshrelease-ci
Integration test with mysql bosh release in Concourse

At first, modify `ci/pipelines/settingCI.yml` whith your bosh credentials.

```sh
fly --target <TARGET> set-pipeline --pipeline=cf-mysql --config=ci/pipelines/cf-mysql.yml -l ci/pipelines/spec.yml -l ci/pipelines/settingCI.yml
```

We test the master branch of bosh release 
 - for cf-mysqsl-release and cf-mysql-deployment
 - for ops release : rometheus, shield, elk


- 1) bosh interpolate with ops : prometheus, shield, elk
- 2) New deployment with ops : prometheus, shield, elk
- 3) upgrade deployment version -1 : prometheus, shield, elk

In parallel :
- 1) bosh interpolate with ops template coab