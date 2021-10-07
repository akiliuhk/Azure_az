#!/bin/bash

az vm create --resource-group devsecops \
  --name $1 \
  --admin-username devsecops \
  --image SUSE:opensuse-leap-15-3:gen2:2021.07.08 \
  --size Standard_B2s \
  --generate-ssh-keys \
  --os-disk-size-gb 80 \
  --custom-data cloud-init.txt
  --no-wait

az vm open-port -g devsecops -n $1 --port 22,80,443, --priority 100



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