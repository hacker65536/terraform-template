resource "aws_ecs_cluster" "ecs" {
  name = "${terraform.workspace}-fargate-cluster"
}
