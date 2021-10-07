#!/bin/bash

# https://aka.ms/cli_ref
# https://docs.microsoft.com/en-us/cli/azure/choose-the-right-azure-command-line-tool?view=azure-cli-latest

# az vm list-usage -l southeastasia
```
Name                                      CurrentValue    Limit
----------------------------------------  --------------  -------
Total Regional vCPUs                      4               10
Virtual Machines                          2               25000
Dedicated vCPUs                           0               3000
Total Regional Low-priority vCPUs         0               10
Standard BS Family vCPUs                  4               10
```
# az vm list-skus -l southeastasia

# az vm list-sizes -l southeastasia
# https://azureprice.net/ for VM pricing comparison
# https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/


```
Size            vCPUs 	Memory(GiB)	    Temporary Storage        Linux Cost	
Standard_B1s  	 1	      1 GiB	         4 GiB                   	$0.0132/hour
Standard_B1ms	   1	      2 GiB	         4 GiB                   	$0.0264/hour
Standard_B2s	   2	      4 GiB	         8 GiB 	                  $0.0528/hour
Standard_B2ms	   2	      8 GiB	         16 GiB	                  $0.106/hour
Standard_B4ms	   4	      16 GiB    	   32 GiB	                  $0.211/hour

```
# az vm image list -f OpenSUSE --all
```
Offer               Publisher                           Sku        Urn                                                              Version
------------------  ----------------------------------  ---------  ---------------------------------------------------------------  ----------
opensuse-gui        noricumcloudsolutions1600524477681  payperuse  noricumcloudsolutions1600524477681:opensuse-gui:payperuse:1.0.1  1.0.1
openSUSE-Leap       SUSE                                15-2       SUSE:openSUSE-Leap:15-2:2020.07.02                               2020.07.02
openSUSE-Leap       SUSE                                15-2-gen2  SUSE:openSUSE-Leap:15-2-gen2:2020.07.02                          2020.07.02
opensuse-leap-15-3  SUSE                                gen1       SUSE:opensuse-leap-15-3:gen1:2021.07.08                          2021.07.08
opensuse-leap-15-3  SUSE                                gen2       SUSE:opensuse-leap-15-3:gen2:2021.07.08                          2021.07.08
```

# cat /Users/akiliu/.azure/config


```
Check latest URN for Ubuntu
az vm image list --location southeastasia --offer UbuntuServer --publisher Canonical --sku 18.04 --all --output table
az group create --name ubu1804-rg --location southeastasia

az vm create --location southeastasia --resource-group ubu1804-rg --name ubu1804 --public-ip-address-dns-name ubu1804 \
--image Canonical:UbuntuServer:18.04-DAILY-LTS:18.04.201804262 --admin-username myuser --admin-password 'SS12345678$$' \
--size Standard_B1ms \
--data-disk-sizes-gb 5 --tags environmenttype=dev owner=harry@oceanliner.com

``` 


# 1. az login
```
az login
```

# 2. Set default location and create resources group
```
az config set defaults.location=southeastasia 
az group create --name devsecops
```
Example output
```
Location       Name
-------------  ---------
southeastasia  devsecops
```

# 3. create VM for devsecops workshop
```

az group delete --name devsecops --yes


az group create --name devsecops
az vm create --resource-group devsecops \
  --name rke-w1 \
  --admin-username devsecops \
  --image SUSE:opensuse-leap-15-3:gen2:2021.07.08 \
  --size Standard_B2s \
  --generate-ssh-keys \
  --os-disk-size-gb 80 \
  --custom-data cloud-init.txt

```
Example output
```
ResourceGroup    PowerState    PublicIpAddress    Fqdns    PrivateIpAddress    MacAddress         Location       Zones
---------------  ------------  -----------------  -------  ------------------  -----------------  -------------  -------
devsecops        VM running    52.163.231.164              10.0.0.4            00-0D-3A-C6-AF-1C  southeastasia
```
# 4. get VM information

```

VM1_IP_ADDR=$(az network public-ip show --ids $IP_ID \
  --query ipAddress \
  -o tsv)
   
ssh -i id_rsa -o StrictHostKeyChecking=no devsecops@$VM1_IP_ADDR


az vm list -g devsecops -d

az vm list-ip-addresses -g devsecops

az vm list-ip-addresses --ids $(az vm list -g devsecops --query "[].id" -o tsv)
az vm list-ip-addresses --query ipAddress --ids $(az vm list -g devsecops --query "[].id" -o tsv)


open Network port
az vm open-port -g MyResourceGroup -n MyVm --port 555,557-559 --priority 100

az vm open-port --ids $(az vm list -g MyResourceGroup --query "[].id" -o tsv) --port '*'

az vm show --name myVM --resource-group devsecops

```
VM1_IP_ADDR=$(az network public-ip show --ids $IP_ID \
  --query ipAddress \
  -o tsv)





### main function
function main(){
local tags=$1
create-key-pair $tags
create-bucket $tags
create-instances $tags-rancher $tags
create-instances $tags-rke-m1 $tags
create-instances $tags-rke-w1 $tags
create-instances $tags-rke-w2 $tags
create-instances $tags-rke-w3 $tags
check-instance-state $tags
put-instance-ports $tags-rancher
put-instance-ports $tags-rke-m1
put-instance-ports $tags-rke-w1
put-instance-ports $tags-rke-w2
put-instance-ports $tags-rke-w3
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
mkdir -p ~/$1-lab-info/
sleep 1
aws lightsail create-key-pair --key-pair-name $tags-default-key --output text --query privateKeyBase64 > ~/$tags-lab-info/$tags-default-key.pem
chmod 600 ~/$tags-lab-info/$tags-default-key.pem
#aws lightsail download-default-key-pair --output text --query publicKeyBase64 > ~/$1-lab-info/$1-default-key.pub
#aws lightsail download-default-key-pair --output text --query privateKeyBase64 > ~/$1-lab-info/$1-default-key.pem
}

### create AWS Lightsail VM
function create-instances(){
local VMname=$1
local tags=$2
sleep 1
aws lightsail create-instances \
  --region ap-southeast-1 \
  --instance-names $VMname \
  --availability-zone ap-southeast-1a \
  --blueprint-id opensuse_15_2 \
  --bundle-id medium_2_0 \
  --ip-address-type ipv4 \
  --key-pair-name $tags-default-key \
  --user-data "systemctl enable docker;systemctl start docker;hostnamectl set-hostname $VMname;" \
  --tags key=$tags \
  --output table \
  --no-cli-pager
}
#   --bundle-id nano_2_0 \
#   --bundle-id medium_2_0 \

### chekc if VM provision
function check-instance-state(){
local $tags=$1
mkdir -p ~/$1-lab-info/

get-instances $tags
while :
do
  if grep -q pending ~/$tags-lab-info/$tags-get-instances.txt
  then
    echo 'pending VM provisioning...'
    get-instances $tags
    sleep 5
  else
    echo 'all VM is up and running'
    get-instances $tags
    break
  fi
done
}

### open ports for AWS Lightsail VM
function put-instance-ports(){
local VMname=$1
sleep 1
aws lightsail put-instance-public-ports \
--port-infos \
"fromPort=22,toPort=22,protocol=TCP" \
"fromPort=80,toPort=80,protocol=TCP" \
"fromPort=443,toPort=443,protocol=TCP" \
"fromPort=2376,toPort=2376,protocol=TCP" \
"fromPort=2379,toPort=2380,protocol=TCP" \
"fromPort=6443,toPort=6443,protocol=TCP" \
"fromPort=10250,toPort=10250,protocol=TCP" \
"fromPort=10254,toPort=10254,protocol=TCP" \
"fromPort=30000,toPort=32767,protocol=TCP" \
"fromPort=8,toPort=-1,protocol=ICMP" \
--instance-name $VMname --output table --no-cli-pager
}


### get AWS Lightsail instance
function get-instances(){
local tags=$1
aws lightsail get-instances --region ap-southeast-1 \
--query "instances[].{$tags:name,publicIpAddress:publicIpAddress,privateIpAddress:privateIpAddress,state:state.name}" \
--output table --no-cli-pager | grep $tags > ~/$tags-lab-info/$tags-get-instances.txt

}

### ssh command into file
function ssh-file(){
local tags=$1
local VMname=$2
local ip=`aws lightsail get-instance --instance-name $VMname --query 'instance.publicIpAddress' --output text --no-cli-pager`
echo "ssh -i ~/$tags-lab-info/$tags-default-key.pem -o StrictHostKeyChecking=no ec2-user@"$ip > ~/$tags-lab-info/ssh-$VMname.sh
chmod 755 ~/$tags-lab-info/ssh-$VMname.sh
}

### ssh command into file
function html-file(){
local tags=$1
local VMname=$2
local port=$3
local ip=`aws lightsail get-instance --instance-name $VMname --query 'instance.publicIpAddress' --output text --no-cli-pager`

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


function create-bucket(){
local tags=$1
cd ~

aws lightsail create-bucket \
  --bucket-name $tags-s3-bucket \
  --bundle-id small_1_0 \
  --output table \
  --no-cli-pager > ~/$tags-lab-info/$tags-s3-bucket.txt
sleep 1

sed -i "" '16,$d'  ~/$tags-lab-info/$tags-s3-bucket.txt

aws lightsail create-bucket-access-key \
  --bucket-name $tags-s3-bucket \
  --output table \
  --no-cli-pager > ~/$tags-lab-info/$tags-s3-bucket-accessKeys.txt
sleep 1

sed -i "" '11,$d'  ~/$tags-lab-info/$tags-s3-bucket-accessKeys.txt
}

main $1
