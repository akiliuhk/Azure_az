#!/bin/bash

az group create --name devsecops

az vm create --resource-group devsecops \
  --name $1 \
  --admin-username az-user \
  --image SUSE:opensuse-leap-15-3:gen2:2021.07.08 \
  --size Standard_B2s \
  --generate-ssh-keys \
  --os-disk-size-gb 80 \
  --custom-data cloud-init.txt

az vm open-port -g devsecops -n $1 --port '*'

az vm show -d -g devsecops -n $1 --query publicIps -o tsv


