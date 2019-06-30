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
for i in *-testing.json; do sed -i.bak 's/"peatusee.azurecr.io\/\([^:"]*\)\+\(:[^"]\+\)*"/peatusee.azurecr.io\/\1:testing"/g' $i ; done
```