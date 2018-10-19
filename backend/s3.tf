resource "aws_s3_bucket" "state" {
  bucket = "${terraform.workspace}-state"
  acl    = "private"
  tags   = "${local.tags}"

  force_destroy = true

  # remove comment and apply when you want to do destroy  

  versioning {
    enabled = true
  }
}

output "bucketname" {
  value = "${aws_s3_bucket.state.id}"
}
