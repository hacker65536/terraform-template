data "template_file" "task" {
  template = "${file("task.json")}"

  vars {
    //image = "${aws_ecr_repository.ecr.repository_url}"
    image = "nginx"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = "${terraform.workspace}-task"
  container_definitions = "${data.template_file.task.rendered}"

  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2", "FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "${aws_iam_role.ecstask.arn}"

  /*
  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
	*/
}
