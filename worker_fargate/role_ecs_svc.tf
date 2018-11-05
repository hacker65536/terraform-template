resource "aws_iam_role" "ecssvc" {
  name               = "${terraform.workspace}-ecssvcRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_ecs.json}"
}

locals {
  ecssvc_role_policies = [
    #for ECS
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",
  ]

  //   "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  //    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
}

resource "aws_iam_role_policy_attachment" "ecssvc" {
  count      = "${length(local.ecssvc_role_policies)}"
  role       = "${aws_iam_role.ecssvc.name}"
  policy_arn = "${element(local.ecssvc_role_policies,count.index)}"
}
