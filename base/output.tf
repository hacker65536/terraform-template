output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "key_pair" {
  value = "${aws_key_pair.key.id}"
}

output "data_s3" {
  value = "${aws_s3_bucket.s3.id}"
}
