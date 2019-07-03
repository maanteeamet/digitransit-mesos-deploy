## Enabling ssh-agent on login / start

https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login

Create a systemd user service, by putting the following to **~/.config/systemd/user/ssh-agent.service**:

```
[Unit]
Description=SSH key agent

[Service]
Type=forking
Environment=SSH_AUTH_SOCK=%t/ssh-agent.socket
ExecStart=/usr/bin/ssh-agent -a $SSH_AUTH_SOCK

[Install]
WantedBy=default.target
```

Setup shell to have an environment variable for the socket (.bash_profile, .zshrc, ...):

```bash
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
```

Enable the service, so it'll be started automatically on login, and start it:

```bash
systemctl --user enable ssh-agent
systemctl --user start ssh-agent
```

Add the following configuration setting to your ssh config file **~/.ssh/config** (this works since SSH 7.2):

```
AddKeysToAgent  yes
```


## generate test env ssh private key

```bash
cd ~/.ssh && ssh-keygen -t rsa -b 4096 -f id_rsa_testing
```

## Generating ssh key for github access

https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent

## Testing for ACS name availability

```bash
export PROJECTNAME=peatusee
export ENVIRONMENT=TESTING
export REGION=westeurope

C=$(dig  ${PROJECTNAME}-${ENVIRONMENT}-acsmgmt.${REGION}.cloudapp.azure.com +short | wc -l)
if [ $C -eq "0" ]; then echo "ACS Name is free"; 
else echo "ACS Name is Taken"; fi;
```

## Create ACS cluster

```bash
cd ~/peatus.ee/digitransit-mesos-deploy
ansible-playbook digitransit-create-acs-testing.yml -e ssh_keys=~/.ssh/id_rsa_testing.pub
```

Verify you can ssh to mesos master agent node

```bash
ssh -i .ssh/id_rsa_testing azureuser@${PROJECTNAME}-${ENVIRONMENT}-acsmgmt.${REGION}.cloudapp.azure.com

```


## Copy deployment playbook files from dev to testing and replace values

```bash
cd ~/peatus.ee/digitransit-mesos-deploy/digitransit-azure-deploy/files
for i in *-dev.json ; do echo $i; name=`echo $i | sed 's/-dev.json/-testing.json/g;'`; echo $name ; cp $i $name; done 
for i in *-testing.json; do sed -i.bak 's/dev.peatus.ee/testing.peatus.ee/g' $i; done 
for i in *-testing.json; do sed -i.bak 's/"peatusee.azurecr.io\/\([^:"]*\)\+\(:[^"]\+\)*"/"peatusee.azurecr.io\/\1:testing"/g' $i ; done
```

## Get list of docker images in dev usage

```bash
grep '"image":' *-dev.json | grep azurecr.io | sed 's/^.*"image": "\(.*\)\+".*$/\1/g' | sort |uniq
```

## Get list of docker images in testing usage

```bash
grep '"image":' *testing.json | grep azurecr.io | sed 's/^.*"image": "\(.*\)\+".*$/\1/g' | sort |uniq
```

## Get docker tags to update

```bash
grep '"image":' *-dev.json | grep azurecr.io | sed 's/^.*"image": "\(.*\)\+".*$/\1/g' | sort |uniq | sed 's/^\([^:]*\)\+\(.*\)$/docker pull \0; docker tag \0 \1:testing; docker push \1:testing/g'

docker pull peatusee.azurecr.io/digitransit-proxy; docker tag peatusee.azurecr.io/digitransit-proxy peatusee.azurecr.io/digitransit-proxy:testing; docker push peatusee.azurecr.io/digitransit-proxy:testing
docker pull peatusee.azurecr.io/digitransit-ui; docker tag peatusee.azurecr.io/digitransit-ui peatusee.azurecr.io/digitransit-ui:testing; docker push peatusee.azurecr.io/digitransit-ui:testing
docker pull peatusee.azurecr.io/hsl-map-server:latest; docker tag peatusee.azurecr.io/hsl-map-server:latest peatusee.azurecr.io/hsl-map-server:testing; docker push peatusee.azurecr.io/hsl-map-server:testing
docker pull peatusee.azurecr.io/opentripplanner; docker tag peatusee.azurecr.io/opentripplanner peatusee.azurecr.io/opentripplanner:testing; docker push peatusee.azurecr.io/opentripplanner:testing
docker pull peatusee.azurecr.io/opentripplanner-data-container-estonia; docker tag peatusee.azurecr.io/opentripplanner-data-container-estonia peatusee.azurecr.io/opentripplanner-data-container-estonia:testing; docker push peatusee.azurecr.io/opentripplanner-data-container-estonia:testing
docker pull peatusee.azurecr.io/otp-data-builder; docker tag peatusee.azurecr.io/otp-data-builder peatusee.azurecr.io/otp-data-builder:testing; docker push peatusee.azurecr.io/otp-data-builder:testing
#docker pull peatusee.azurecr.io/otp-data-builder:next; docker tag peatusee.azurecr.io/otp-data-builder:next peatusee.azurecr.io/otp-data-builder:testing; docker push peatusee.azurecr.io/otp-data-builder:testing
#docker pull peatusee.azurecr.io/otp-data-builder:prod; docker tag peatusee.azurecr.io/otp-data-builder:prod peatusee.azurecr.io/otp-data-builder:testing; docker push peatusee.azurecr.io/otp-data-builder:testing
docker pull peatusee.azurecr.io/pelias-api; docker tag peatusee.azurecr.io/pelias-api peatusee.azurecr.io/pelias-api:testing; docker push peatusee.azurecr.io/pelias-api:testing
docker pull peatusee.azurecr.io/pelias-elastic; docker tag peatusee.azurecr.io/pelias-elastic peatusee.azurecr.io/pelias-elastic:testing; docker push peatusee.azurecr.io/pelias-elastic:testing
docker pull peatusee.azurecr.io/pelias-interpolation; docker tag peatusee.azurecr.io/pelias-interpolation peatusee.azurecr.io/pelias-interpolation:testing; docker push peatusee.azurecr.io/pelias-interpolation:testing
docker pull peatusee.azurecr.io/pelias-libpostal; docker tag peatusee.azurecr.io/pelias-libpostal peatusee.azurecr.io/pelias-libpostal:testing; docker push peatusee.azurecr.io/pelias-libpostal:testing
docker pull peatusee.azurecr.io/pelias-pip; docker tag peatusee.azurecr.io/pelias-pip peatusee.azurecr.io/pelias-pip:testing; docker push peatusee.azurecr.io/pelias-pip:testing
docker pull peatusee.azurecr.io/pelias-placeholder; docker tag peatusee.azurecr.io/pelias-placeholder peatusee.azurecr.io/pelias-placeholder:testing; docker push peatusee.azurecr.io/pelias-placeholder:testing


```

## Get all tags in remote registry (not tested against private ACR)

https://stackoverflow.com/questions/28320134/how-to-list-all-tags-for-a-docker-image-on-a-remote-registry/39485542

```bash
image="$1"
tags=`wget -q https://registry.hub.docker.com/v1/repositories/${image}/tags -O -  | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n'  | awk -F: '{print $3}'`
```

## Jenkins: getting commit id 

https://issues.jenkins-ci.org/browse/JENKINS-34455

commitId = sh(returnStdout: true, script: 'git rev-parse HEAD')

https://github.com/jenkinsci/pipeline-examples/blob/master/pipeline-examples/gitcommit/gitcommit.groovy

https://github.com/storj/complex/blob/master/Jenkinsfile


## Jenkins: Build name setter plugin

https://wiki.jenkins.io/display/JENKINS/Build+Name+Setter+Plugin

## Jenkins: Git parameter plugin

https://wiki.jenkins.io/display/JENKINS/Git+Parameter+Plugin

## Active Choice parameters

https://kublr.com/blog/how-to-use-advanced-jenkins-groovy-scripting-for-live-fetching-of-docker-images/

https://lukasmestan.com/jenkins-pipeline-example-scripts/

https://stackoverflow.com/questions/51923836/working-with-images-in-azure-container-registry-via-rest

## Scaling DCOS cluster down

1. Stop applications
On DCOS master (you need to install dcos command before)

```bash
apps=$(dcos marathon app list |cut -f 1 -d " " | grep -v "^ID$")
for i in $apps ; do echo "Stopping $i"; dcos marathon app stop $i ; done
```

2. Change cluster private nodes count
3. restart applications

```bash
apps=$(dcos marathon app list |cut -f 1 -d " " | grep -v "^ID$")
for i in $apps ; do echo "Stopping $i"; dcos marathon app start $i ; done
```


## Docker images tagging in remote without pulling images

TODO: 

https://dille.name/blog/2018/09/20/how-to-tag-docker-images-without-pulling-them/

