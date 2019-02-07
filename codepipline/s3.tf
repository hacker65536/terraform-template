resource "aws_s3_bucket" "codepipeline" {
  bucket = "${terraform.workspace}-codep"
  acl    = "private"
}
