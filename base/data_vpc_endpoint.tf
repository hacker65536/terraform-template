data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

data "aws_vpc_endpoint_service" "secretsmanager" {
  service = "secretsmanager"
}
