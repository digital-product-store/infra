# summary

creates digital-product-store infra on AWS.

uses `aws`, `kubernetes` and `helm` providers.

## flow

- creates a new vpc named `main` with 3 public subnets and 4 private subnets (2 members of each group are owned by eks cluster), sets an internet gateway and a nat gateway. (see: `vpc.tf`)
- creates ECR for `user` and `product` services' images, creates a new user:group and allows it push image via AWS credentials for CI purposes (see: `ecr.tf`)
- creates a new s3 bucket which is needed by product service, (see `s3.tf`)
- initialize a new EKS cluster named `store`, sets a open id provider for it that can be used for service account authentication, installs a alb controller and sets a node group (see: `eks.tf`)
- installs istio with using its helm chart repository (see: `istio.tf`)
- creates a new ingress (see: `ingress.tf`)
- installs request authentication conf package from digital-product-store's helm repository (see: `request_auth.tf`)
- sets a new rds subnet group, allows eks cluster to connect and create a new instance (see: `rds.tf`)
- create a new role, allows it being able to connect rds and s3 (see: `product_iam.tf`)

## output variables

- **ci_ecr_user_access_credentials**: CI user access key id and secret (sensitive)
- **product_db_endpoint**: hostname and port combination of RDS instance for product service
- **product_http_role_arn**: role arn for service account of product service
- **services_product_ecr_registry**: product service registry information
- **services_user_ecr_registry**: user service registry information