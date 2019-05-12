#!/bin/bash
set -e
if [ -z $1 ];
   then
	   echo "Usage: ./deploy.sh %app_name% %app_version%"
	   exit 1
fi

if [ -z $2 ];
   then
           echo "Usage: ./deploy.sh %app_name% %app_version%"
           exit 1
fi

if [ ! -s ~/.aws/credentials ];
   then
	   echo "You should put your AWS credentals to ~/.aws/credentials file"
	   exit 1
fi

LOGIN=`aws sts get-caller-identity 2>&1`
if [ $? -ne "0" ];
   then
	   echo "Could not login to AWS, please check your credentials"
	   exit 1
   else
	   ACCOUNTID=`echo $LOGIN | jq .Account | tr -d "\""`
	   echo "Logged in into account $ACCOUNTID"
fi

export ACCOUNTID
export USERARN=`echo $LOGIN | jq .Arn | tr -d "\""`

echo "Deploying registry..."

aws cloudformation deploy --template-file ./infra/registry.yml --stack-name $1 --parameters ParameterKey=Title,ParameterValue=$1 ParameterKey=AccountArn,ParameterValue=$USERARN --capabilities CAPABILITY_IAM

echo "Building and pushing image..."
$(aws ecr get-login --no-include-email)
docker build -t $ACCOUNTID.dkr.ecr.eu-west-1.amazonaws.com/$1:$2 ./docker
docker build -t $ACCOUNTID.dkr.ecr.eu-west-1.amazonaws.com/$1:latest ./docker
docker push $ACCOUNTID.dkr.ecr.eu-west-1.amazonaws.com/$1:$2
docker push $ACCOUNTID.dkr.ecr.eu-west-1.amazonaws.com/$1:latest

echo "Updating stack...."
aws cloudformation update-stack --stack-name $1 --template-body ./infra/infra.yml --parameters ParameterKey=AccountId,ParameterValue=$ACCOUNTID ParameterKey=Title,ParameterValue=$1 ParameterKey=ImageVersion,ParameterValue=$2 --capabilities CAPABILITY_IAM 
