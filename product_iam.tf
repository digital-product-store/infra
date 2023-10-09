data "aws_caller_identity" "current" {}

# Service Account for Product HTTP Service
## Document
data "aws_iam_policy_document" "product_http_service_role_trust_doc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.store_openid.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.store_openid.url, "https://", "")}:sub"

      values = [
        "system:serviceaccount:${var.product_service_namespace}:${var.product_service_account_name}",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.store_openid.url, "https://", "")}:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }
  }
}

## Role
resource "aws_iam_role" "product_http_role" {
  name               = "product-http-role"
  assume_role_policy = data.aws_iam_policy_document.product_http_service_role_trust_doc.json
}

## Policy Document
data "aws_iam_policy_document" "product_http_access_policy_doc" {
  statement {
    actions = ["s3:PutObject", "rds-db:connect"]

    resources = [
      "${aws_s3_bucket.product_uploads.arn}/*",
      "arn:aws:rds-db:${var.aws_region}:${data.aws_caller_identity.current.account_id}:dbuser:${aws_db_instance.product_db.resource_id}/${var.product_db_username}"
    ]
  }
}
## Policy Creation
resource "aws_iam_policy" "product_http_access_policy" {
  name   = "product-http-access-policy"
  policy = data.aws_iam_policy_document.product_http_access_policy_doc.json

}
## Policy Attachment
resource "aws_iam_role_policy_attachment" "product_http_policy_attachment" {
  role       = aws_iam_role.product_http_role.name
  policy_arn = aws_iam_policy.product_http_access_policy.arn
}

output "product_http_role_arn" {
  value = aws_iam_role.product_http_role.arn
}
