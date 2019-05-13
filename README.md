Sample implementation of IaC with AWS Cloudformation and ECS.

To deploy your app do the foollowing:
1) put your AWS credentials into ~/.aws/credentials
2) run ./deploy.sh supplying app_name and app_version as arguments

Currently implemented pipeline:
- create ECR docker registry with proper permissions
- build and push application image into ECR registry
- create the rest of the infra based on ECS cluster
- deploy application into this cluster
