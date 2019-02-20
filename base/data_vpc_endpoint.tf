data "aws_vpc_endpoint_service" "s3" {
  service = "s3"
}

data "aws_vpc_endpoint_service" "secretsmanager" {
  service = "secretsmanager"
}

data "aws_vpc_endpoint_service" "codebuild" {
  service = "codebuild"
}

data "aws_vpc_endpoint_service" "codepipeline" {
  service = "codepipeline"
}

data "aws_vpc_endpoint_service" "ecr_api" {
  service = "ecr.api"
}

data "aws_vpc_endpoint_service" "ecr_dkr" {
  service = "ecr.dkr"
}

data "aws_vpc_endpoint_service" "logs" {
  service = "logs"
}
