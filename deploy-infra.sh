STACK_NAME=good-parts
REGION=us-east-1
CLI_PROFILE=default
EC2_INSTANCE_TYPE=t2.micro

echo -e "\n\n\nDeploying main.yml\n"
aws cloudformation deploy \
    --region $REGION \
    --profile $CLI_PROFILE \
    --stack-name $STACK_NAME \
    --template-file main.yml \
    --no-fail-on-empty-changeset \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        EC2InstanceType=$EC2_INSTANCE_TYPE

if [ $? -eq 0 ]; then
    aws cloudformation list-exports \
        --profile $CLI_PROFILE \
        --query "Exports[?Name=='InstanceEndpoint'].Value"
fi
