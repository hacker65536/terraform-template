resource "aws_ecr_repository" "ecr" {
  name = "${terraform.workspace}-ecr"
}

output "ecr_name" {
  value = "${aws_ecr_repository.ecr.name}"
}

output "ecr_url" {
  value = "${aws_ecr_repository.ecr.repository_url}"
}
