data "aws_iam_policy_document" "ecr" {
  statement {
    sid = "from code build"

    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadForLayer",
    ]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}
