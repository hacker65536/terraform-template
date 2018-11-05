data "template_file" "task" {
  template = "${file("task.json")}"

  vars {
    image  = "${data.aws_ecr_repository.ecr.repository_url}"
    master = "${aws_instance.master.private_ip}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = "${terraform.workspace}-task"
  container_definitions = "${data.template_file.task.rendered}"

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
