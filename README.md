Ansible Azure roles for digitransit deployment
=========

Roles built to deploy a digitransit to microsoft azure platform 

It will deploy: 

* Azure application gateway for SSL offload and traffic managment
* Azure container service using DC/OS as the orchestrator
* Digitransit docker containers from dockerhub to run the service
* CDN service to host static content for digitransit project. 


some example playbooks are included and can be executed like so.

ansible-playbook -i playbookname.yml 

environment_type: PROD or DEV can be passed to the playbook for deploying the correct config
some playbooks required ssh keys to be setup for creating services in azure

set the location of your ssh keys according to which keys should be used to create the environment. 

i.e. 

ansible-playbook digitransit-create-acs.yml --extra-vars "ssh_keys=/home/username/.ssh/key.pub environment_type=PROD"

Azure SSL 
-----------
cat STAR_dev_peatus_ee.crt USERTrustRSAAddTrustCA.crt SectigoRSADomainValidationSecureServerCA.crt AddTrustExternalCARoot.crt > cert.crt
openssl pkcs12 -export -out wc_dev.pfx -inkey dev_peatus_ee_2.key -in  cert.crt
<enter random password>

Upload pfx to Application gateway (Listeners) and use same password that was in last step.


Requirements
------------

AZURE xplat-cli needs to be installed and default subscription set. 
SSH tunel to DC/OS master


License
-------

BSD


Author Information
------------------

mark.bryan@cgi.com
