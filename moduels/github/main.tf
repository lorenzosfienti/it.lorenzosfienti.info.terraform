data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.reponame}:*"]
    }
  }
}

resource "aws_iam_role" "github" {
  name               = "${var.project}-github-oidc"
  assume_role_policy = data.aws_iam_policy_document.github.json
  managed_policy_arns = [
    aws_iam_policy.manage_bucket.arn
  ]
}

resource "aws_iam_policy" "manage_bucket" {
  name        = "${var.project}-github-bucket"
  description = "Allow Github to uploads files to bucket"
  path        = "/bitbucket/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Effect = "Allow"
        Resource = [
          var.bucket_arn,
          "${var.bucket_arn}/*"
        ]
      },
    ]
  })
}