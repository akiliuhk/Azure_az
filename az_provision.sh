#!/bin/bash

### main function
function main(){
local tags=$1
create-key-pair $tags
create-instances $tags $tags-rancher
create-instances $tags $tags-rke-m1 
create-instances $tags $tags-rke-w1
create-instances $tags $tags-rke-w2
create-instances $tags $tags-rke-w3
put-instance-ports $tags $tags-rancher
put-instance-ports $tags $tags-rke-m1
put-instance-ports $tags $tags-rke-w1
put-instance-ports $tags $tags-rke-w2
put-instance-ports $tags $tags-rke-w3
get-instances $tags
ssh-file $tags $tags-rancher
ssh-file $tags $tags-rke-m1
ssh-file $tags $tags-rke-w1
ssh-file $tags $tags-rke-w2
ssh-file $tags $tags-rke-w3
html-file $tags $tags-rancher 80
html-file $tags $tags-rke-w1 30080
html-file $tags $tags-rke-w1 31080
tar-file $tags
}


### create key pair for each $tag 
function create-key-pair (){
local tags=$1
mkdir -p ~/$tags-lab-info/
sleep 1

az configure --defaults location=southeastasia
az group create --name $tags
cp -pr ~/.ssh/id_rsa ~/$tags-lab-info/$tags-default-key.pem
chmod 600 ~/$tags-lab-info/$tags-default-key.pem

}

### create AWS Lightsail VM
function create-instances(){
local tags=$1
local VMname=$2
sleep 1
mkdir -p ~/$tags-lab-info/
sleep 1

az vm create --resource-group $tags \
  --name $VMname \
  --admin-username az-user \
  --image SUSE:opensuse-leap-15-3:gen2:2021.07.08 \
  --size Standard_B2s \
  --generate-ssh-keys \
  --os-disk-size-gb 80 \
  --custom-data cloud-config.txt \
  --no-wait \
  --verbose 
}

### open ports for AWS Lightsail VM
function put-instance-ports(){
local tags=$1
local VMname=$2
sleep 1

az vm open-port -g $tags -n $VMname --port 22,80,443,2376,2379-2380,6443,10250,10254,30000-32767 --priority 100
}


### get AWS Lightsail instance
function get-instances(){
local tags=$1
az vm list -g $tags -d > ~/$tags-lab-info/$tags-get-instances.txt
}

### ssh command into file
function ssh-file(){
local tags=$1
local VMname=$2

local ip=$(az vm show -d -g $tags -n $VMname --query publicIps -o tsv)

echo "ssh -i ~/$tags-lab-info/$tags-default-key.pem -o StrictHostKeyChecking=no az-user@"$ip > ~/$tags-lab-info/ssh-$VMname.sh
chmod 755 ~/$tags-lab-info/ssh-$VMname.sh
}

### ssh command into file
function html-file(){
local tags=$1
local VMname=$2
local port=$3
local ip=$(az vm show -d -g $tags -n $VMname --query publicIps -o tsv)

cd ~/$tags-lab-info

cat > "$VMname-port-$port.html" << EOF
<html>
<head>
<meta http-equiv="refresh" content="0; url=http://$ip:$port" />
</head>
</html>
EOF

}

### tar lab folder
function tar-file(){
local tags=$1
cd ~
tar -cvzf $tags-lab-info.tar.gz $tags-lab-info
}

main $1

