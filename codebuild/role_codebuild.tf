resource "aws_iam_role" "codebuild" {
  name               = "${terraform.workspace}-codebuild-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_codebuild.json}"
}

locals {
  codebuild_role_policies = [
    #for codebuild
    "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess",

    #for ssm
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
  ]
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  count      = "${length(local.codebuild_role_policies)}"
  role       = "${aws_iam_role.codebuild.name}"
  policy_arn = "${element(local.codebuild_role_policies,count.index)}"
}

data "aws_iam_policy_document" "codebuildvpc" {
  statement {
    sid = "1"

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
    sid = "2"

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
}

resource "aws_iam_role_policy" "codebuild" {
  name = "${terraform.workspace}-codebuild-vpc"
  role = "${aws_iam_role.codebuild.id}"

  policy = "${data.aws_iam_policy_document.codebuildvpc.json}"
}
