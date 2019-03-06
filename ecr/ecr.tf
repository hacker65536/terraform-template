resource "aws_ecr_repository" "ecr" {
  name = "${terraform.workspace}-ecr"
}

resource "aws_ecr_repository_policy" "ecr" {
  repository = "${aws_ecr_repository.ecr.name}"
  policy     = "${data.aws_iam_policy_document.ecr.json}"
}

output "ecr_name" {
  value = "${aws_ecr_repository.ecr.name}"
}
