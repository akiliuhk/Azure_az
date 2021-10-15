#!/bin/bash -ex

### delete azure resource group
function delete-instance(){

local tags=$1
rm -fr ~/$tags-lab-info
rm -f ~/$tags-lab-info.tar.gz

az group delete --name $tags --yes
}

delete-instance $1
