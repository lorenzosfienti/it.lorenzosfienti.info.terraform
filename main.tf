# Using the official Terraform Module to create the Bucket that will contains the files of website
# https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${local.project}-bucket"
}

# Retrieve the Managed Caching Optimized
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-cache-policies.html#managed-cache-caching-optimized
data "aws_cloudfront_cache_policy" "managed_caching" {
  name = "Managed-CachingOptimized"
}

# Using the offical Terraform Module to create CDN
# https://registry.terraform.io/modules/terraform-aws-modules/cloudfront/aws/latest
module "cdn" {
  source          = "terraform-aws-modules/cloudfront/aws"
  aliases         = [local.domain]
  comment         = "${local.project}-cdn"
  enabled         = true
  is_ipv6_enabled = true
  # About the PriceClass show the documentation of AWS
  # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false

  # We create thge OAI to give the permission for CDN to access at the file inside the bucket
  create_origin_access_identity = true
  origin_access_identities = {
    bucket = "${local.project}-oai"
  }

  origin = {
    bucket = {
      domain_name = module.bucket_cdn.bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "bucket"
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "bucket"
    viewer_protocol_policy = "allow-all"
    cache_policy_id        = data.aws_cloudfront_cache_policy.managed_caching.id
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    query_string           = true
    use_forwarded_values   = false
  }

  viewer_certificate = {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response = [{
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
    }, {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }]
}

# Create certificate. 
# The DNS Validation will be outside because the DNS of website it's managed by Cloudflare
resource "aws_acm_certificate" "cert" {
  domain_name       = local.domain
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}


# Module Custom to add a policy to the Bucket to give read access to files to the CDN.
module "bucket_cdn" {
  source                                     = "./moduels/bucket-cdn"
  bucket_id                                  = module.bucket.s3_bucket_id
  cloudfront_origin_access_identity_iam_arns = module.cdn.cloudfront_origin_access_identity_iam_arns
}

# Module Custom to add the permission to upload files inside the bucket to Github repo with project
module "github" {
  source     = "./moduels/github"
  bucket_arn = module.bucket.s3_bucket_arn
  project    = local.project
  reponame   = local.reponame
}
