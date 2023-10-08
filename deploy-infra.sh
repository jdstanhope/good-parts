STACK_NAME=good-parts
REGION=us-east-1
CLI_PROFILE=default
EC2_INSTANCE_TYPE=t2.micro
AWS_ACCOUNT_ID=`aws sts get-caller-identity --profile $CLI_PROFILE --query "Account" --output text`
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"
CFN_BUCKET="$STACK_NAME-cfn-$AWS_ACCOUNT_ID"
DOMAIN=lets-play-tag.com
CERT=`aws acm list-certificates --region us-east-1 --profile default --output text --query "CertificateSummaryList[?DomainName=='lets-play-tag.com'].CertificateArn | [0]"`

# These values come from the env
# GH_ACCESS_TOKEN
# GH_OWNER
# GH_REPO
# GH_BRANCH

echo -e "\n\n\nDeploying setup.yml\n"
aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME-setup \
    --template-file setup.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        CodePipelineBucket=$CODEPIPELINE_BUCKET \
        CloudFormationBucket=$CFN_BUCKET

echo -e "\n\n\nPaccessing main.yml\n"
mkdir -p ./cfn_output

PACKAGE_ERR="$(aws cloudformation package \
    --region $REGION \
    --profile $CLI_PROFILE \
    --template main.yml \
    --s3-bucket $CFN_BUCKET \
    --output-template-file ./cfn_output/main.yml 2>&1)"
if ! [[ $PACKAGE_ERR =~ "Successfully packaged artifacts" ]]; then
    echo "Error while running 'aws cloudformation package' command:"
    echo "$PACKAGE_ERR"
    exit 1
fi

echo -e "\n\n\nDeploying main.yml\n"
aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME \
    --template-file ./cfn_output/main.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        EC2InstanceType=$EC2_INSTANCE_TYPE \
        GitHubOwner=$GH_OWNER \
        GitHubRepo=$GH_REPO \
        GitHubBranch=$GH_BRANCH \
        GitHubPersonalAccessToken=$GH_ACCESS_TOKEN \
        CodePipelineBucket=$CODEPIPELINE_BUCKET \
        Domain=$DOMAIN \
        Certificate=$CERT

if [ $? -eq 0 ]; then
    aws cloudformation list-exports \
        --profile $CLI_PROFILE \
        --query "Exports[?ends_with(Name, 'LBEndpoint')].Value"
fi
