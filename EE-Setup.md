## Intro

This is Maanteeamet's deployment scenario for Digitransit application for Estonian area

## Prequisites

### Knowledge about: 
* Ansible
* Mesos
* Git
* Docker & Docker-compse
* Azure

### Azure rights

* User account in AAD which subscription trusts with admin access to Subscription which will be used to host application
* Permissions to create or order Service Principal in AAD

### DNS registry 
* Domain/subdomain you will use for application deployment - aka *dev.peatus.ee*
* Admin access for you subdomain to register neccessary entries

### Admin workstation

For bootstrapping, you will need linux/mac machine, you cannot use Windows workstation as Ansible control station

#### Install Ansible
In workstation:
* Install Ansible
  * For Ubuntu:
```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update
sudo apt-get install ansible -y
```
* Verify that ansible & ansible-playbook commands are working

#### Install Azure CLI (az command)


```bash
sudo apt-get update
sudo apt-get install curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null

AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

sudo apt-get update
sudo apt-get install azure-cli

```
For latest instructions go to
* [https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)


#### Install Azure xplat-cli (azure command)

Install npm
```
sudo apt install npm
npm install -g azure-cli
```

Two versions of Azure cli is required because deployment scripts have mixed dependencies

### Set environment variables

TODO

### SSH Keys

If you have ssh keypair you wish to use, this step is not necessary.
However, be notified that in Azure Container Service, you cannot change
ssh keypair after cluster has been created, so you might want to create
dedicated keypair for this application.

In Admin workstation do:

```bash
cd ~/.ssh && ssh-keygen -t rsa -b 4096 -f id_rsa_dev
```

## Part 1 - Setup Azure resources

### 1.1 Prepare Azure Subscription

* (Optional) Create subscription for application
* Log into admin station
* Log into Azure using Azure CLI and select subscription to work on

#### Login

```bash
az login
az account set --subscription "your-subscription-id"
```

#### Create Service Principal

Create Service Principal which has full admin rights for Subscription. NB! 
Copy Service principal login information, it will not be shown again!

```bash
az ad sp create-for-rbac --name "YourPrincipalName"
```
Result will be something like this:
```json
{
  "appId": "your-app-id",
  "displayName": "YourPrincipalName",
  "name": "http://YourPrincipalName",
  "password": "your-app-password",
  "tenant": "your-tenant-id"
}
``` 
#### Grant Service Principal rights

Grant Service Principal Owner role to subscription

```bash
az role assignment create --assignee "your-app-id"  --role Owner
```
Verify that Service Principal has Owner role assigned
```bash
az role assignment list --assignee  "your-app-id"
```

#### Log into into Azure as Service Principal

```bash
az login --service-principal --username "your-app-id" --password "your-app-password" --tenant "your-tenant-id"
azure login -u "<service-principal-id>" -p "<key>" --service-principal --tenant "<tenant-id>"
```
You are now logged in to Azure with Service Principal. Use Service Principal login for all further tasks when deploying application to Azure to minimize potential costly mistakes.

If you had any trouble, check manual for latest instructions: 
* [https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest)


### 1.2 Prepare resource playbooks

Pull repo: https://github.com/maanteeamet/digitransit-mesos-deploy

```bash
mkdir -p ~/peatus.ee && cd ~/peatus.ee && git clone https://github.com/maanteeamet/digitransit-mesos-deploy
```


TODO: This part is creepy. Find a way to store secrets outside repo. 

Set your ansible vault password.

!NB! You need later on to replace docker user and password within encrypted file

```bash
ANSIBLE_VAULT_KEY=YourVaultPassword
cd ~/peatus.ee/digitransit-mesos-deploy 
echo $ANSIBLE_VAULT_KEY > vault_password
cat group_vars/all/unencrypted.yml | sed "s/^ansible_secret: .*$/ansible_secret: \"$ANSIBLE_VAULT_KEY\"/g" > group_vars/all/encrypted.yml
ansible-vault encrypt group_vars/all/encrypted.yml

```

### 1.3 Create DNS Zone

Create DNS Zone for your application in Azure

for example: 
dev.peatus.ee

TODO: Create ansible playbook for this.


### 1.4 Create Azure Container Registry

**NB!** This service is shared between environments.  
**NB!** If setting up for new environment, make sure that ACR name is unique. Name also needs to be unique for ACS cluster.  
**NB!** If changing ACR name to a new one, you need to replace ACR in all of deployment scripts.  
**NB!** You need to enable Admin login for ACR.  
 
Check is you desired name is free:
```bash
PROJECTNAME=peatustest
ENVIRONMENT=dev
REGION=westeurope

C=$(dig  $PROJECTNAME.azurecr.io +short | wc -l)
if [ $C -eq "0" ]; then echo "ACR Name is free"; else echo "ACR Name is Taken"; fi;

C=$(dig  ${PROJECTNAME}-${ENVIRONMENT}-acsmgmt.${REGION}.cloudapp.azure.com +short | wc -l)
if [ $C -eq "0" ]; then echo "ACS Name is free"; 
else echo "ACS Name is Taken"; fi;
```

**Proceed only if you desider ACR and ACS names are free!!!**

Replace project name in deployment files. 

**NB!** replacing project name is necessary if you decide to use new ACR, if you use existing one, set project 
name to to existing ACR name (default peatusee from peatusee.azurecr.io ).

```bash
PROJECTNAME=peatustest
cd ~/peatus.ee/digitransit-mesos-deploy
find . -type f  | xargs sed -i "s/peatusee/${PROJECTNAME}/g"
```

TODO: Use variables for ACR name in scripts where possible.

Create ACR, enable admin access and retrieve secrets
```bash
PROJECTNAME=peatustest
ansible-playbook digitransit-create-acr.yml
az acr update -n ${PROJECTNAME} --admin-enabled true
az acr credential show -n ${PROJECTNAME} --query username
az acr credential show -n ${PROJECTNAME} --query passwords[0].value
```

TODO: Create docker secrets file  
TODO: Update group_vars/all/encrypted.yml docker secrets values


### 1.5 Create ACS cluster


Choose whether to run dev, test or prod environment by selecting correct playbook file.

For dev environment creation
```bash
cd ~/peatus.ee/digitransit-mesos-deploy
ansible-playbook digitransit-create-acs-dev.yml -e ssh_keys=~/.ssh/id_rsa_dev.pub
```

Verify you can ssh to mesos master agent node
```bash
PROJECTNAME=peatustest
ENVIRONMENT=dev
REGION=westeurope

ssh -i .ssh/id_rsa_dev azureuser@${PROJECTNAME}-${ENVIRONMENT}-acsmgmt.${REGION}.cloudapp.azure.com
```



### 1.6 Create Azure AppGW


#### SSL certificate 

You should have SSL certificate for application DNS domain. 
If you have SSL certificate, put it into PFX file and store somewhere in admin server.

To create self-signed certificate, use 
```bash
cd ~/peatus.ee/digitransit-mesos-deploy/self_signed_ssl
./create.sh
```
This will create self-signed certificate in that folder.

Choose which environment to run and either change digitransit-create-appgw-ENVIRONMENT.yml file or
use extra values argument for ansible-playbook.

To run dev environment with default settings:
```bash
cd ~/peatus.ee/digitransit-mesos-deploy
ansible-playbook digitransit-create-appgw-dev.yml
```

To run dev environment with custom SSL certificate :
```bash
cd ~/peatus.ee/digitransit-mesos-deploy
ansible-playbook digitransit-create-appgw-dev.yml \
-e certfile=~/peatus.ee/digitransit-mesos-deployself_signed_ssl/test.pfx \
-e certpass=fM2hkebDfcPq
```

### 1.7 Install Jenkins server

We are currently installing one Jenkins per cluster - cannot use VNET peering otherwise.


#### 1.7.1 Create Jenkins with ansible playbook:
```bash
cd ~/peatus.ee/digitransit-mesos-deploy
ansible-playbook digitransit-create-jenkins.yml -e environment_type=TESTING -e ssh_keys=~/.ssh/id_rsa_testing.pub
```


#### 1.7.2 OR Create Azure resources for Jenkins VM:

```bash
# set your project name
PROJECTNAME=peatustest
RESOURCEGROUP=${PROJECTNAME}-jenkins-CI
REGION=westeurope
VNETNAME=${PROJECTNAME}-jenkins-CI-vnet

az group create --name ${RESOURCEGROUP} --location ${REGION}
az network vnet create -g ${RESOURCEGROUP} -n ${VNETNAME} --address-prefix 172.16.1.0/24 \
  --subnet-name default --subnet-prefix 172.16.1.0/24

az vm create -n jenkins -g ${RESOURCEGROUP} --image centos --vnet-name ${VNETNAME} --subnet default \
  --private-ip-address 172.16.1.4 \
  --admin-username azureuser \
  --size Standard_DS2_v3 \
  --ssh-key-value @~/.ssh/id_rsa_dev.pub

az vm open-port -g ${RESOURCEGROUP} -n jenkins --port 80
az vm open-port -g ${RESOURCEGROUP} -n jenkins --port 443

```

#### Give DNS name for Jenkins machine.

Use Portal for now. 

I gave name 

**peatusee-jenkins-testing.westeurope.cloudapp.azure.com**

for TESTING environment

Create A record jenkins.testing.peatus.ee in Azure DNS zone configured previously. Verify you can connect by name.

```bash
ssh -i .ssh/id_rsa_testing azureuser@jenkins.${ENVIRONMENT}.peatus.ee

```


#### Verify you can log into jenkins VM


```bash
export PROJECTNAME=peatusee
export ENVIRONMENT=TESTING
export REGION=westeurope
export RESOURCEGROUP=${PROJECTNAME}-${ENVIRONMENT}-jenkins-RG
export JENKINSIP=$(az vm list-ip-addresses --name jenkins -g ${RESOURCEGROUP} | grep "ipAddress" | sed 's/^.*": "//g' |sed 's/",//g')
ssh -i .ssh/id_rsa_testing azureuser@${JENKINSIP}

```

Alternatively use DNS name registered in previous step to connect



#### Peer jenkins-CI and dcos-vnet-xxx vnets

NB! this is only required to download docker secrets to mesos nodes securely.
Since you cannot configure AZ ACS VNETs freely, this solution does not work with multiple ACS clusters and one jenkins VNET - 
VNET address spaces will conflict.


##### Peer Using Azure CLI

**NB!** For some reason, it cannot be created with AZ cli at moment. Please use AZ Portal to peer networks.
```bash
PROJECTNAME=peatustest
ENVIRONMENT=DEV
JENKINS_RESOURCEGROUP=${PROJECTNAME}-jenkins-CI
DCOS_RESOURCEGROUP=${PROJECTNAME}-${ENVIRONMENT}-ACS-RG
REGION=westeurope

JENKINS_VNETNAME=${PROJECTNAME}-jenkins-CI-vnet
DCOS_VENTNAME=$(az network vnet list --query "[?contains(name, 'dcos')]" | grep 'name": "dcos-vnet' | sed 's/^.*": "//g' |sed 's/",//g')

az network vnet peering create -g ${JENKINS_RESOURCEGROUP} -n jenkins-to-mesos --vnet-name ${JENKINS_VNETNAME} \
                            --remote-vnet ${DCOS_VENTNAME} --allow-vnet-access
az network vnet peering create -g ${DCOS_RESOURCEGROUP} -n mesos-to-jenkins --vnet-name ${DCOS_VNETNAME} \
                            --remote-vnet ${JENKINS_VENTNAME} --allow-vnet-access


```

##### Peer VNET-s in Azure Portal

Link jenkins network with the container network - so mesos can download the ACR secrets that are provided by jenkins machines apche. ( "http://172.16.1.4/docker.tar.gz" must be reachable)  
Jenkins network is peatusee-jenkins-CI-vnet , the ACS network for dev is for example dcos-vnet-5535DF10.  
To do this you need to click on one of the virtual netwroks, selest "Peerings", click "Add" (I recomend to start from jenkins vnet)  
Name it jenkins-mesos-dev  
* Select "Virtual Network" the dcos-vnet-* thet you need to add.
* Configure virtual network access settings - enabled
* Configure forwarded traffic settings - enabled
* Configure gateway transit settings - not selected
* Configure Remote Gateways settings - not selected

Repeat the same steps for the other network - but switch the netwroks. (Name it mesos-jenkins-dev)
Check if you can ping jenkins internal IP from mesos master.


Log into mesos master and try to ping jenkins internal ip (172.16.1.4)

##### Configure jenkins installation

Follow [https://github.com/maanteeamet/digitransit-mesos-deploy/blob/master/jenkins/centos_install.txt](https://github.com/maanteeamet/digitransit-mesos-deploy/blob/master/jenkins/centos_install.txt) for configuring Jenkins server


##### Configure jenkins user access to mesos cluster

**!NB!** TODO: in this section, correct names for your installation need to substituded

Add jenkins machines jenkins users public key to masters ~/.authrorized_keys - jenkins needs to be able to log in to masters to initiate service restarts after building new images. 

If that is not desired then you can skip this step - perhaps for production you wish to initiate these manually.
```bash
ssh azureuser@jenkins.dev.peatus.ee  
$ sudo su
# cat /var/lib/jenkins/.ssh/id_rsa.pub  <Copy the key>
```
In another terminal:
```bash
ssh -i id_rsa_dev azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com
vim .ssh/authorized_keys <add new line with jenkins public key>
```
Check from jenkins console, if you can log in to master:
```
# su - jenkins -s /bin/bash
ssh azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com
```

When logged into the mesos master, you can also check if you can download the docker secret with "wget -O /dev/null http://172.16.1.4/docker.tar.gz"


##### Configure access to Marathon UI through jenkins server

>**NB!** This is kind of a hacky approach - not working for multi-master. Actual access should be build using App Proxy in front of master LB. 
>
>Marathon SSL/Basic auth access can be configured https://mesosphere.github.io/marathon/docs/ssl-basic-access-authentication.html and access could be provided by making LB public IP available to certain IP addresses 
>for management purposes but requires then also password injection to jenkins scripts. 
>
>Should redesign.

In Azure DNS, register alias marathon which points to jenkins machine

In **Jenkins** machine:

1. Set up marathon port 80 setting

```bash
export DOMAINNAME=testing.peatus.ee; 
sudo -E -- sh -c 'wget -q "https://raw.githubusercontent.com/maanteeamet/digitransit-mesos-deploy/master/jenkins/CloudInit/marathon.conf" -O - | sed "s/#DOMAINNAME#/$DOMAINNAME/g" > /etc/httpd/conf.d/marathon.conf'
sudo systemctl restart httpd
```

2. Run certbot installation

```bash
sudo certbot --apache
```
**NB!** - certbot should already have renewing cron task scheduled but if required, it can be set up by:

```bash
sudo -- sh -c 'echo "0 0,12 * * * python -c '"'"'import random; import time; time.sleep(random.random() * 3600)'"'"' && certbot renew" > /etc/cron.d/certbot'
cat /etc/cron.d/certbot
```

3. Add http user

```bash
sudo htpasswd -c /etc/httpd/marathon.htpasswd mntadmin
```
4. Set up proxy pass to DCOS master node

```bash
export DOMAINNAME=testing.peatus.ee; 
sudo -E -- sh -c 'wget -q "https://raw.githubusercontent.com/maanteeamet/digitransit-mesos-deploy/master/jenkins/CloudInit/marathon-le-ssl.conf" -O - | sed "s/#DOMAINNAME#/$DOMAINNAME/g" > /etc/httpd/conf.d/marathon-le-ssl.conf'
sudo systemctl restart httpd
```

## Part 2 - Set up containers in Mesos

**NB!** This part here is unverified

Before launching containers into Mesos, create SSH link to master: (get the hostname from azure portal - it is the masters hostname (click on dcos-master-*, get DNS name from right)

Log in to admin station.

```bash
ssh -i ~/.ssh/id_rsa_dev -L 5436:localhost:80 -f -N azureuser@peatusee-dev-acsmgmt.westeurope.cloudapp.azure.com
```

Then you should be able to create containers.
```bash
ansible-playbook digitransit-manage-containers.yml --tags deploy --extra-vars "environment_type=DEV"
```

**This only again works if you CAN connect VNETs.**
**separate JENKINS for testing environment seems to be fastest way to deploy this without chaning toom much**

Setup new maratchon, use for example the dev setup:

Create http/80TCP vritual host first and use certbot to create SSL for it.

/etc/httpd/conf.d/dev-marathon.conf

For certificates use "certbot --apache"


When SSL setup is done for you, use the 

/etc/httpd/conf.d/dev-marathon-le-ssl.conf file for example.

For http auth use "htpasswd -c /etc/httpd/dev-marathon.htpasswd mntadmin"

Add DNS records to your DNS zone in azure to point to jenkins - see existing examples.

Go to https://marathon.dev.peatus.ee - 


Setup SSL certificates for APPGW - 
Select APPGW for your env in azure portal.
Select Listeners
Select HTTPS Listener, click "Renew or edit selected certificate" and follow instructions.

To create pfx format certificate that azure wants use:
cat STAR_dev_peatus_ee.crt USERTrustRSAAddTrustCA.crt SectigoRSADomainValidationSecureServerCA.crt AddTrustExternalCARoot.crt > cert.crt
openssl pkcs12 -export -out wc_dev.pfx -inkey dev_peatus_ee_2.key -in  cert.crt

enter random password

Upload pfx to Application gateway (Listeners) and use same password that was in last step.



Create additional DNS records for your enviroment - point them towards APPGW

If for some reason you need to log in to one of the worker nodes, log into the mesos master, add the private key to /root/.ssh/id_rsa and then you can use ssh from master to log into workers.


After first startup you might have to restart digitransit-ui and hsl-map-server. See logs for issues.

## Part 3 Configure Jenkins pipelines for rebuilds

Todo