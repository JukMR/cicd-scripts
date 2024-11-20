#!/bin/bash
set -eu

# Check required inputs
if [ $# -ne 2 ]; then
    echo "::error::Usage: $0 <environment> <account>"
    exit 1
fi

environment="$1"
account="$2"

# Set environment variables based on inputs
case "$environment" in
"prd")
    echo "AWS_ROLE_ARN=$PRODDS_AWS_CICD_DEPLOYMENT_ROLE" >>"$GITHUB_ENV"
    case "$account" in
    "general")
        echo "bucket_name=financial-services-test" >>"$GITHUB_OUTPUT"
        ;;
    "banking")
        echo "bucket_name=financial-services-test" >>"$GITHUB_OUTPUT"
        ;;
    *)
        echo "::error::Invalid configuration"
        exit 1
        ;;
    esac
    ;;
"dev")
    echo "AWS_ROLE_ARN=$DEVDS_AWS_CICD_DEPLOYMENT_ROLE" >>"$GITHUB_ENV"
    case "$account" in
    "general")
        echo "bucket_name=financial-services-test" >>"$GITHUB_OUTPUT"
        ;;
    "banking")
        echo "bucket_name=financial-services-test" >>"$GITHUB_OUTPUT"
        ;;
    *)
        echo "::error::Invalid configuration"
        exit 1
        ;;
    esac
    ;;
*)
    echo "::error::Invalid environment: $environment"
    exit 1
    ;;
esac
