#!/bin/bash

set -eu

# set -x # Uncomment to debug this script

if [ -z "${AWS_ROLE_ARN}" ]; then
    echo "::error:: AWS_ROLE_ARN is not set"
    exit 1
fi

# Assume role and export credentials
credentials=$(aws sts assume-role \
    --role-arn "$AWS_ROLE_ARN" \
    --role-session-name gh-actions-call \
    --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
    --output text)

read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<<"$credentials"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN

# Check if AWS credentials were obtained
if [ -z "${AWS_ACCESS_KEY_ID}" ] || [ -z "${AWS_SECRET_ACCESS_KEY}" ] || [ -z "${AWS_SESSION_TOKEN}" ]; then
    echo "::error:: Failed to obtain AWS credentials"
    exit 1
fi

# Mask sensitive values
echo "::add-mask::$AWS_ACCESS_KEY_ID"
echo "::add-mask::$AWS_SECRET_ACCESS_KEY"
echo "::add-mask::$AWS_SESSION_TOKEN"

# Export to GitHub environment
{
    echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}"
    echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}"
    echo "AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN}"
} >>"${GITHUB_ENV}"
