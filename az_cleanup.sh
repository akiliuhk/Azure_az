#!/bin/bash -ex

### delete azure resource group
function cleanup(){

local tags=$1
rm -fr ~/$tags-lab-info
rm -f ~/$tags-lab-info.tar.gz

az group delete --name $tags --yes

}

cleanup $1
