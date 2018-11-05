resource "aws_iam_role" "ecstask" {
  name               = "${terraform.workspace}-ecstaskexecRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_ecs_tasks.json}"
}

locals {
  ecstasks_role_policies = [
    #for ECS
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
  ]

  //   "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  //    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
}

resource "aws_iam_role_policy_attachment" "ecstask" {
  count      = "${length(local.ecstasks_role_policies)}"
  role       = "${aws_iam_role.ecstask.name}"
  policy_arn = "${element(local.ecstasks_role_policies,count.index)}"
}
