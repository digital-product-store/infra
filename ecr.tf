resource "aws_ecr_repository" "services_user" {
  name = "user"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "user"
  }
}

resource "aws_iam_user" "ci_ecr_user" {
  name = var.ci_ecr_user_name
  force_destroy = true

  tags = {
    Name = "CI"
  }
}

resource "aws_iam_group" "ci_ecr_group" {
  name = var.ci_ecr_group_name
}

resource "aws_iam_group_membership" "ci_user_group_membership" {
  name = "ci-user-group-membership"
  users = [aws_iam_user.ci_ecr_user.name]
  group = aws_iam_group.ci_ecr_group.name
}

data "aws_iam_policy_document" "services_registry_push_policy" {
 statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
 }

 statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]

    resources = [
      aws_ecr_repository.services_user.arn
    ]
 }
}

resource "aws_iam_policy" "allow_access_services_ecr" {
  name = "allow-access-services-ecr"
  description = "policy allows access to services ecr"
  policy = data.aws_iam_policy_document.services_registry_push_policy.json
}

resource "aws_iam_group_policy_attachment" "ci-group-services-ecr-attachment" {
  group = aws_iam_group.ci_ecr_group.name
  policy_arn = aws_iam_policy.allow_access_services_ecr.arn
}

resource "aws_iam_access_key" "ci_ecr_user_access_key" {
  user = aws_iam_user.ci_ecr_user.name
}

output "services_user_ecr_registry" {
    value = {
        url = aws_ecr_repository.services_user.repository_url
        arn = aws_ecr_repository.services_user.arn
    }
}

output "ci_ecr_user_access_credentials" {
  value = {
    ci_ecr_user_access_key_id = aws_iam_access_key.ci_ecr_user_access_key.id
    ci_ecr_user_access_key_secret = aws_iam_access_key.ci_ecr_user_access_key.secret
  }
  sensitive = true
}
