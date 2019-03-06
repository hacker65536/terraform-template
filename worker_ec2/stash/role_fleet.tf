resource "aws_iam_role" "fleet" {
  name               = "${terraform.workspace}-SpotFleetRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_spotfleet.json}"
}

locals {
  role_policies_fleet = [
    #for spotfeet
    "arn:aws:iam::aws:policy/service-role/AmazonEC2SpotFleetRole",
  ]

  //   "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",

  #for PMM
  //    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
}

resource "aws_iam_role_policy_attachment" "fleet" {
  count      = "${length(local.role_policies_fleet)}"
  role       = "${aws_iam_role.fleet.name}"
  policy_arn = "${element(local.role_policies_fleet,count.index)}"
}
