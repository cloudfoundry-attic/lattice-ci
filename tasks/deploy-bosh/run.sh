#!/bin/bash

set -e

echo "$BOSH_PRIVATE_KEY" > bosh.pem

set -x

TEMPLATE_PATH=$PWD/lattice-ci/tasks/deploy-bosh/cloudformation.json

if aws cloudformation describe-stacks --stack-name "$CLOUDFORMATION_STACK_NAME" >/dev/null 2>/dev/null; then
  aws cloudformation update-stack --stack-name "$CLOUDFORMATION_STACK_NAME" --template-body "file://$TEMPLATE_PATH" || true
else
  aws cloudformation create-stack --stack-name "$CLOUDFORMATION_STACK_NAME" --template-body "file://$TEMPLATE_PATH"
fi

while true; do
  STACK_INFO=$(aws cloudformation describe-stacks --stack-name "$CLOUDFORMATION_STACK_NAME")
  STATUS=$(echo "$STACK_INFO" | jq -r .Stacks[0].StackStatus)

  if [[ ${PIPESTATUS[0]} != 0 ]]; then
    echo "Failed to describe stacks."
    exit 1
  fi

  if [[ $STATUS = "ROLLBACK_COMPLETE" ]]; then
    echo "Create failed."
    exit 1
  fi

  if [[ $STATUS = "UPDATE_ROLLBACK_COMPLETE" ]]; then
    echo "Update failed."
    exit 1
  fi

  if [[ $STATUS = "CREATE_COMPLETE" ]] ; then
    echo "$STATUS"
    break
  fi

  sleep 5
done

function get_stack_output() {
  echo "$STACK_INFO" | jq -r "[ .Stacks[0].Outputs[] | { (.OutputKey): .OutputValue } | .$1 ] | add"
}

ELASTIC_IP=$(get_stack_output MicroEIP)
SUBNET_ID=$(get_stack_output BOSHSubnetID)
AVAILABILITY_ZONE=$(get_stack_output AvailabilityZone)
SECURITY_GROUP_ID=$(get_stack_output BOSHSecurityGroupID)
SECURITY_GROUP_NAME=$(aws ec2 describe-security-groups --group-ids=$SECURITY_GROUP_ID | jq -r .SecurityGroups[0].GroupName)

cp lattice-ci/tasks/deploy-bosh/manifest.yml .

sed -i "s/AVAILABILITY-ZONE/$AVAILABILITY_ZONE/g" manifest.yml
sed -i "s/ELASTIC-IP/$ELASTIC_IP/g" manifest.yml
sed -i "s/ACCESS-KEY-ID/$AWS_ACCESS_KEY_ID/g" manifest.yml
sed -i "s/SECRET-ACCESS-KEY/$AWS_SECRET_ACCESS_KEY/g" manifest.yml
sed -i "s/SUBNET-ID/$SUBNET_ID/g" manifest.yml
sed -i "s/SECURITY-GROUP-NAME/$SECURITY_GROUP_NAME/g" manifest.yml

bosh-init deploy manifest.yml
