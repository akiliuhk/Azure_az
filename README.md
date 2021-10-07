# Azure az vm basic usage

# Azure vCPU limitation 
#### Azure Account default 4vCPU for Free trial account
#### Azure Account default 10vCPU for PAYG account

Example error output when reached 4vCPU limitation as a free trial account
```
{"error":{"code":"InvalidTemplateDeployment","message":"The template deployment 'vm_deploy_UbiBOqlV5EWbnWWjQliH3AQRkso948dP' is not valid according to the validation procedure. The tracking id is '7b0fbbcc-41cd-4144-8426-9f3d011b373c'. See inner errors for details.","details":[{"code":"QuotaExceeded","message":"Operation could not be completed as it results in exceeding approved Total Regional Cores quota. Additional details - Deployment Model: Resource Manager, Location: southeastasia, Current Limit: 4, Current Usage: 4, Additional Required: 2, (Minimum) New Limit Required: 6. Submit a request for Quota increase at https://aka.ms/ProdportalCRP/#blade/Microsoft_Azure_Capacity/CapacityExperienceBlade/Parameters/%7B%22subscriptionId%22:%22c0396603-64f0-4b16-9396-9d30ed0eae05%22,%22command%22:%22openQuotaApprovalBlade%22,%22quotas%22:[%7B%22location%22:%22southeastasia%22,%22providerId%22:%22Microsoft.Compute%22,%22resourceName%22:%22cores%22,%22quotaRequest%22:%7B%22properties%22:%7B%22limit%22:6,%22unit%22:%22Count%22,%22name%22:%7B%22value%22:%22cores%22%7D%7D%7D%7D]%7D by specifying parameters listed in the ‘Details’ section for deployment to succeed. Please read more about quota limits at https://docs.microsoft.com/en-us/azure/azure-supportability/regional-quota-requests"}]}}
```
#### az vm list-usage -l southeastasia
```
Name                                      CurrentValue    Limit
----------------------------------------  --------------  -------
Total Regional vCPUs                      4               10
Virtual Machines                          2               25000
Dedicated vCPUs                           0               3000
Total Regional Low-priority vCPUs         0               10
Standard BS Family vCPUs                  4               10
```
https://docs.microsoft.com/en-us/azure/azure-portal/supportability/per-vm-quota-requests

# Increase vCPU limitation

1. upgrade your free trial account to pay as you go account (it may took 15 minutes to effective)
2. from the Azure portal home page, Subscription, select default subscripition, Usage + quotas
3. please change the Standard BS Family vCPUs to 20 (which means we can have 10 * 2vCPU VM)



# az vm list-skus -l southeastasia

## az vm list-sizes -l southeastasia
### https://azureprice.net/ for VM pricing comparison
### https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/

- checked the Bs-series VM is the cheapest we can found and comparable to AWS Lightsail

Bs-series
Bs-series are economical virtual machines that provide a low-cost option for workloads that typically run at a low to moderate baseline CPU performance, but sometimes need to burst to significantly higher CPU performance when the demand rises. These workloads don’t require the use of the full CPU all the time, but occasionally will need to burst to finish some tasks more quickly. Many applications such as development and test servers, low traffic web servers, small databases, micro services, servers for proof-of-concepts, build servers, and code repositories fit into this model.

```
Size             vCPUs 	     Memory(GiB)	    Temporary Storage       Linux Cost	
Standard_B1s  	   1	      1 GiB	             4 GiB                  $0.0132/hour
Standard_B1ms	   1	      2 GiB	             4 GiB                  $0.0264/hour
Standard_B2s	   2	      4 GiB	             8 GiB 	                $0.0528/hour
Standard_B2ms	   2	      8 GiB	             16 GiB	                $0.106/hour
Standard_B4ms	   4	      16 GiB             32 GiB	                $0.211/hour

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

# Example guide of Azure vm create
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment


# 1. az login
```
az login
```

# 2. Set default location and create resources group
```
az group delete --name devsecops --yes

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
az vm create --resource-group devsecops \
  --name rancher \
  --admin-username devsecops \
  --image SUSE:opensuse-leap-15-3:gen2:2021.07.08 \
  --size Standard_B2s \
  --ssh-key-name devsecops_sshkey \
  --os-disk-size-gb 80 \
  --custom-data cloud-init.txt
```

## 3.1 cloud-config.txt
```
#cloud-config

packages:
  - curl
  - sudo
  - docker
  - wget 
  - iputils 
  - vim

# create the docker group
groups:
  - docker

# Add default auto created user to docker group
system_info:
  default_user:
    groups: [docker]
    
runcmd:
  - sudo systemctl enable docker
  - sudo systemctl start docker
```

Example output
```
Name     ResourceGroup    PowerState    PublicIps      Fqdns    Location       Zones
-------  ---------------  ------------  -------------  -------  -------------  -------
rancher  devsecops        VM running    52.187.178.1            southeastasia

```
# 4. open ALL VM port 

```
az vm open-port -g devsecops -n rke-w1 --port '*'

az vm open-port --ids $(az vm list -g devsecops --query "[].id" -o tsv) --port '*'
```
Example output
```
Location       Name        ProvisioningState    ResourceGroup    ResourceGuid
-------------  ----------  -------------------  ---------------  ------------------------------------
southeastasia  rancherNSG  Succeeded            devsecops        916c44e3-5171-4ba0-a3dd-9f44b3cee145
southeastasia  rke-m1NSG   Succeeded            devsecops        31ed7213-ea37-48b5-85d9-a508ce219da9
```

# 5. get VM info

```
az vm list -g devsecops -d
```
Example output
```
Name     ResourceGroup    PowerState    PublicIps      Fqdns    Location       Zones
-------  ---------------  ------------  -------------  -------  -------------  -------
rancher  devsecops        VM running    52.187.178.1            southeastasia
rke-m1   devsecops        VM running    20.205.191.36           southeastasia
rke-w1   devsecops        VM running    52.230.39.211           southeastasia
rke-w2   devsecops        VM running    40.65.135.87            southeastasia
rke-w3   devsecops        VM running    52.230.36.125           southeastasia
```

# 6. get specified VM public IP address by VM name

```
az vm show -d -g devsecops -n rancher --query publicIps -o tsv
```
Example output
```
52.187.74.168
```

# 7. ssh into VM

```
export ip=$(az vm show -d -g devsecops -n rancher --query publicIps -o tsv)

ssh -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no devsecops@$ip
```

