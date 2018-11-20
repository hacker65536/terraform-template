resource "aws_iam_role" "ec2" {
  name               = "${terraform.workspace}-ec2"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_ec2.json}"
}

locals {
  ec2_role_policies = [
    #for SSM
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
  ]

  #for ECS
  //  "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",

  //   "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",

  #for PMM
  //    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
}

resource "aws_iam_role_policy_attachment" "ec2" {
  count      = "${length(local.ec2_role_policies)}"
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${element(local.ec2_role_policies,count.index)}"
}

resource "aws_iam_role_policy" "ec2" {
  name = "test_policy"
  role = "${aws_iam_role.ec2.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "secretsmanager:getSecretValue*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${aws_iam_role.ec2.name}"
  role = "${aws_iam_role.ec2.name}"
}
