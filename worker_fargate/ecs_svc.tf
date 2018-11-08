resource "aws_ecs_service" "nginx" {
  name            = "nginx"
  cluster         = "${aws_ecs_cluster.ecs.id}"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  desired_count   = 1
  depends_on      = ["aws_iam_role.ecssvc"]

  launch_type = "FARGATE"

  network_configuration {
    subnets          = ["${data.aws_subnet_ids.pub.ids}"]
    security_groups  = ["${data.aws_security_group.sec.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target.arn}"
    container_name   = "nginx"
    container_port   = 80
  }

  /*
  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
	*/

  depends_on = [
    "aws_lb_listener.http",
    "aws_lb.lb",
    "aws_lb_target_group.target.",
  ]
}
