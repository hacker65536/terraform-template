data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = "vpc1"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "vpc2"

    actions = [
      "ec2:CreateNetworkInterfacePermission",
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.region.name}:${data.aws_caller_identity.caller_id.account_id}:network-interface/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = ["${data.aws_subnet.pri_nat.*.arn}"]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"

      values = [
        "codebuild.amazonaws.com",
      ]
    }
  }

  statement {
    sid = "logs1"

    actions = [
      "logs:CreateLogGroup",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "logs2"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.region.name}:${data.aws_caller_identity.caller_id.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.codebuild.name}:log-stream:*",
    ]

    //"${aws_cloudwatch_log_group.codebuildlogs.arn}:log-stream:*",
    //"arn:aws:logs:${data.aws_region.region.name}:${data.aws_caller_identity.caller_id.account_id}:log-group:/aws/codebuild/${aws_codebuild_project.codebuild.name}",
  }

  statement {
    sid = "s3"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.codebuild.arn}/*",
    ]
  }

  statement {
    sid = "ecr1"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "ecr2"

    actions = [
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
    ]

    resources = [
      "${data.aws_ecr_repository.ecr.arn}",
    ]
  }

  statement {
    sid = "kms"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      "*",
    ]
  }
}
