# Retrive the bucket resource by ID of the Bucket
data "aws_s3_bucket" "bucket" {
  bucket = var.bucket_id
}

# Generates an IAM policy document in JSON format to give the read permission of Bucket to the Cloudfront 
data "aws_iam_policy_document" "bucket_s3_policy" {
  statement {
    sid       = "1"
    actions   = ["s3:GetObject"]
    resources = ["${data.aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = var.cloudfront_origin_access_identity_iam_arns
    }
  }
}

# Attach the policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = data.aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_s3_policy.json
}