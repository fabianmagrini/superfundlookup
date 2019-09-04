#!/bin/bash

# Overide settings on the command line
# ARG1 is environmentID
# ARG2 is containerRegistryName (optional)
if [ $# -eq 0 ]
then
  deployYamlTemplate=aks-superfundapi.yaml.template
else
  deployYamlTemplate=$1
fi

# set variables
#export subscriptionid="..."
#export tenantid="..."

# read the yaml template from a file and substitute the variable strings 
template=`cat "$deployYamlTemplate" | sed "s/{{subscriptionid}}/$subscriptionid/g"`
template=`echo "$template" | sed "s/{{tenantid}}/$tenantid/g"`

# apply the yaml with the substituted values
#echo "$template" | kubectl apply -f -
echo "$template" 