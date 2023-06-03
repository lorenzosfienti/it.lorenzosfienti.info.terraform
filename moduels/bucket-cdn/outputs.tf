output "bucket_regional_domain_name" {
  description = ""
  value       = data.aws_s3_bucket.bucket.bucket_regional_domain_name
}