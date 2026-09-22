# Register GitHub Actions as an OpenID Connect (OIDC) identity provider.
# This allows GitHub Actions to authenticate with AWS without storing
# long-lived AWS access keys in GitHub.

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  # AWS Security Token Service (STS) is the intended recipient
  # of the identity token issued by GitHub.

  client_id_list = [
    "sts.amazonaws.com"
  ]
}
# Create an IAM role that the GitHub Actions workflow can assume.
# The trust policy restricts access to the main branch of this repository.
resource "aws_iam_role" "github_actions" {
  name = "github-actions-resume-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:gbrod1/AWS-Cloud-Resume:ref:refs/heads/main"
          }
        }
      }
    ]
  })
}

# Give the GitHub Actions role permission to deploy the frontend.
# Access is limited to this project's S3 bucket and CloudFront distribution.

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "github-actions-resume-deploy-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        # Allow GitHub Actions to upload, update, and remove website files.
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:DeleteObject"
        ]

        Resource = "${aws_s3_bucket.resume_website.arn}/*"
      },
      {
        # Allow the deployment workflow to read the bucket contents.
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.resume_website.arn
      },
      {
        # Allow GitHub Actions to clear CloudFront's cached website files
        # after a deployment so visitors receive the latest version.

        Effect = "Allow"

        Action = [
          "cloudfront:CreateInvalidation"
        ]

        Resource = aws_cloudfront_distribution.s3_distribution.arn
      }
    ]
  })
}