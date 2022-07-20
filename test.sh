#!/bin/bash

set -e

# Iterate through examples
# Check examples.json-template to figure the indexes of each configuration

i=$1
# instance_name=$( jq -r ".[$i].provision_params.instance_name" examples.json)
instance_name=test
INSTANCE_NAME=${2:-$instance_name}

example_name=$(jq -r ".[$i].name" examples.json)
echo "Running Example $i: $example_name"

provision_params=$( jq -r ".[$i].provision_params" examples.json)
bind_params=$( jq -r ".[$i].bind_params" examples.json)

if (jq ".[$i].description" examples.json | grep -q "(K8S)"); then
  INSTANCE_NAME=$INSTANCE_NAME K8S_CLOUD_PROVISION_PARAMS="$provision_params" K8S_CLOUD_BIND_PARAMS=$bind_params make k8s-demo-up
  INSTANCE_NAME=$INSTANCE_NAME make k8s-demo-down
else
  echo $INSTANCE_NAME
  echo $provision_params
  echo $bind_params
  INSTANCE_NAME=$INSTANCE_NAME ECS_CLOUD_PROVISION_PARAMS="$provision_params" ECS_CLOUD_BIND_PARAMS="$bind_params" make ecs-demo-up
  INSTANCE_NAME=$INSTANCE_NAME make ecs-demo-down
fi
