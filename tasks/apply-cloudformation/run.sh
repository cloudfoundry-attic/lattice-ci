#!/bin/bash

set -ex

TEMPLATE_PATH=$PWD/lattice-ci/tasks/apply-cloudformation/cloudformation.json

if aws cloudformation describe-stacks --stack-name "$CLOUDFORMATION_STACK_NAME" >/dev/null 2>/dev/null; then
  aws cloudformation update-stack --stack-name "$CLOUDFORMATION_STACK_NAME" \
    --parameters ParameterKey=LoadBalancerCertName,ParameterValue="$CERTIFICATE_NAME" \
    --template-body "file://$TEMPLATE_PATH" || true
else
  aws cloudformation create-stack --stack-name "$CLOUDFORMATION_STACK_NAME" \
    --parameters ParameterKey=LoadBalancerCertName,ParameterValue="$CERTIFICATE_NAME" \
    --template-body "file://$TEMPLATE_PATH"
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
