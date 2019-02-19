data "aws_kms_alias" "kms" {
  name = "alias/${terraform.workspace}-kms"
}
