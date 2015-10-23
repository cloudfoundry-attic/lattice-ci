#!/bin/bash

curl -L -J -O https://bosh.io/d/github.com/concourse/concourse?v=$CONCOURSE_VERSION
curl -L -J -O https://bosh.io/d/github.com/cloudfoundry-incubator/garden-linux-release?v=$GARDEN_LINUX_VERSION
curl -L -J -O https://bosh.io/d/stemcells/bosh-aws-xen-hvm-ubuntu-trusty-go_agent

export STACK_INFO=`aws cloudformation describe-stacks --stack-name "$CLOUDFORMATION_STACK_NAME"`

export SECURITY_GROUP_ID=$(get_stack_output "SecurityGroupID")
export SECURITY_GROUP_NAME=$(aws ec2 describe-security-groups --group-ids=$SECURITY_GROUP_ID | jq -r .SecurityGroups[0].GroupName)
export PRIVATE_SUBNET_ID=$(get_stack_output "PrivateSubnetID")
export ELB_NAME=$(get_stack_output "ElasticLoadBalancer")

cp ./lattice-ci/tasks/deploy-concourse/manifest.yml .

export MANIFEST_FILE=$PWD/manifest.yml

sed -i "s/BOSH_UUID/$BOSH_UUID/g" $MANIFEST_FILE
sed -i "s/SECURITY_GROUP_NAME/$SECURITY_GROUP_NAME/g" $MANIFEST_FILE
sed -i "s/PRIVATE_SUBNET_ID/$PRIVATE_SUBNET_ID/g" $MANIFEST_FILE
sed -i "s/ELB_NAME/$ELB_NAME/g" $MANIFEST_FILE
