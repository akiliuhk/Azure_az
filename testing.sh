#!/bin/bash

az group create --name devsecops
az vm create --resource-group devsecops \
  --name $1 \
  --admin-username devsecops \
  --image SUSE:opensuse-leap-15-3:gen2:2021.07.08 \
  --size Standard_B2s \
  --generate-ssh-keys \
  --os-disk-size-gb 80 \
  --custom-data cloud-init.txt
  --no-wait
