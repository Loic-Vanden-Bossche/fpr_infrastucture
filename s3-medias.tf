data "aws_iam_policy_document" "bucket_policy_document" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      aws_s3_bucket.bucket_medias.arn,
      "${aws_s3_bucket.bucket_medias.arn}/*"
    ]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai_medias.iam_arn]
    }
  }
}

resource "aws_s3_bucket" "bucket_medias" {
  bucket_prefix = "fpr-medias"
  tags = {
    "Project"   = var.domain_name
    "ManagedBy" = "Terraform"
  }
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket_medias_acl_ownership" {
  bucket = aws_s3_bucket.bucket_medias.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


resource "aws_s3_bucket_public_access_block" "public_block_medias" {
  bucket                  = aws_s3_bucket.bucket_medias.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_policy" "bucket_medias_policy" {
  bucket = aws_s3_bucket.bucket_medias.id
  policy = data.aws_iam_policy_document.bucket_policy_document.json
}
