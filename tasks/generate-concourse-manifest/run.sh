#!/bin/bash
set -ex

STACK_INFO=`aws cloudformation describe-stacks --stack-name "$CLOUDFORMATION_STACK_NAME"`

function get_stack_output() {
  echo "$STACK_INFO" | jq -r "[ .Stacks[0].Outputs[] | { (.OutputKey): .OutputValue } | .$1 ] | add"
}

SECURITY_GROUP_ID=$(get_stack_output BOSHSecurityGroupID)
SECURITY_GROUP_NAME=$(aws ec2 describe-security-groups --group-ids=$SECURITY_GROUP_ID | jq -r .SecurityGroups[0].GroupName)
PRIVATE_SUBNET_ID=$(get_stack_output InternalSubnetID)
ELB_NAME=$(get_stack_output WebELBLoadBalancerName)

cp lattice-ci/tasks/generate-concourse-manifest/manifest.yml .

sed -i "s/BOSH_UUID/$BOSH_UUID/g" manifest.yml
sed -i "s/CONCOURSE_USERNAME/$CONCOURSE_USERNAME/g" manifest.yml
sed -i "s/CONCOURSE_PASSWORD/$CONCOURSE_PASSWORD/g" manifest.yml
sed -i "s/SECURITY_GROUP_NAME/$SECURITY_GROUP_NAME/g" manifest.yml
sed -i "s/PRIVATE_SUBNET_ID/$PRIVATE_SUBNET_ID/g" manifest.yml
sed -i "s/ELB_NAME/$ELB_NAME/g" manifest.yml
