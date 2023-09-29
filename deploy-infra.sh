STACK_NAME=good-parts
REGION=us-east-1
CLI_PROFILE=default
EC2_INSTANCE_TYPE=t2.micro
AWS_ACCOUNT_ID=`aws sts get-caller-identity --profile $CLI_PROFILE --query "Account" --output text`
CODEPIPELINE_BUCKET="$STACK_NAME-$REGION-codepipeline-$AWS_ACCOUNT_ID"

echo -e "\n\n\nDeploying main.yml\n"
aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME \
    --template-file main.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        CodePipelineBucket=$CODEPIPELINE_BUCKET \
        EC2InstanceType=$EC2_INSTANCE_TYPE

if [ $? -eq 0 ]; then
    aws cloudformation list-exports \
        --profile $CLI_PROFILE \
        --query "Exports[?Name=='InstanceEndpoint'].Value"
fi
