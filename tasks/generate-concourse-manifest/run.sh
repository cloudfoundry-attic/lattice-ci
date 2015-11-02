#!/bin/bash
set -e

bosh -t "$BOSH_TARGET" login admin "$BOSH_PASSWORD"

set -x

STACK_INFO=`aws cloudformation describe-stacks --stack-name "$CLOUDFORMATION_STACK_NAME"`

function get_stack_output() {
  echo "$STACK_INFO" | jq -r "[ .Stacks[0].Outputs[] | { (.OutputKey): .OutputValue } | .$1 ] | add"
}

BOSH_UUID=$(bosh -n --color -t "$BOSH_TARGET" status --uuid)
SECURITY_GROUP_ID=$(get_stack_output InternalSecurityGroupID)
SECURITY_GROUP_NAME=$(aws ec2 describe-security-groups --group-ids=$SECURITY_GROUP_ID | jq -r .SecurityGroups[0].GroupName)
PRIVATE_SUBNET_ID=$(get_stack_output InternalSubnetID)
ELB_NAME=$(get_stack_output WebELBLoadBalancerName)

FORMATTED_CONCOURSE_TSA_PUBLIC_KEY=$(echo "CONCOURSE_TSA_PUBLIC_KEY" | perl -p -e 's/\n/\\n/g')

cp lattice-ci/tasks/generate-concourse-manifest/manifest.yml .

sed -i "s/BOSH-UUID/$BOSH_UUID/g" manifest.yml
sed -i "s/CONCOURSE-USERNAME/$CONCOURSE_USERNAME/g" manifest.yml
sed -i "s/CONCOURSE-PASSWORD/$CONCOURSE_PASSWORD/g" manifest.yml
sed -i "s%TSA-PRIVATE-KEY%$CONCOURSE_TSA_PRIVATE_KEY%g" manifest.yml
sed -i "s/TSA-PUBLIC-KEY/$FORMATTED_CONCOURSE_TSA_PUBLIC_KEY/g" manifest.yml
sed -i "s/SECURITY-GROUP-NAME/$SECURITY_GROUP_NAME/g" manifest.yml
sed -i "s/PRIVATE-SUBNET-ID/$PRIVATE_SUBNET_ID/g" manifest.yml
sed -i "s/ELB-NAME/$ELB_NAME/g" manifest.yml
