# Azure_az

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

## az vm list-sizes -l southeastasia
### https://azureprice.net/ for VM pricing comparison
### https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/


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
# 4. open ALL VM port 

```
az vm open-port --ids $(az vm list -g devsecops --query "[].id" -o tsv) --port '*'
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
```