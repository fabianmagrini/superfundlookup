#!/bin/bash

# set execution context (if necessary)
#az account set --subscription <replace with your subscription name or id>

# Modify for your environment.
environmentID=$RANDOM
containerRegistryName=SuperFundContainerRegistry

../SuperFundACR/setup.sh $environmentID $containerRegistryName