resource "aws_s3_bucket" "product_uploads" {
  bucket = var.product_uploads_s3_bucket_name

  tags = {
    "Name" = var.product_uploads_s3_bucket_name
  }
}
