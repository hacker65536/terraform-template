resource "aws_iam_role" "codepipeline" {
  name               = "${terraform.workspace}-codepipeline"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_codepipeline.json}"
}

locals {
  codepipeline_role_policies = [
    #for SSM
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
  ]

  #for ECS
  //  "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",

  //   "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",

  #for PMM
  //    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
}

resource "aws_iam_role_policy_attachment" "codepipeline" {
  count      = "${length(local.codepipeline_role_policies)}"
  role       = "${aws_iam_role.codepipeline.name}"
  policy_arn = "${element(local.codepipeline_role_policies,count.index)}"
}

resource "aws_iam_role_policy" "codepipeline" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.codepipeline.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline.arn}",
        "${aws_s3_bucket.codepipeline.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
