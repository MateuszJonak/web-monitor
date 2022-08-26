data "aws_iam_user" "github_user" {
  user_name = "github-user"
}

resource "aws_iam_policy" "github_ci_policy" {
  name        = "github-ci-policy"
  path        = "/"
  description = "Github CI policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.frontend_bucket.arn}",
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "github_ci_attachment" {
  name       = "github_ci_attachment"
  users      = [data.aws_iam_user.github_user.user_name]
  policy_arn = aws_iam_policy.github_ci_policy.arn
}