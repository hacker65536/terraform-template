locals {
  asggroup = [
    "",
  ]
}

resource "aws_autoscaling_group" "asg" {
  count = "${length(local.asggroup)}"

  //desired_capacity          = 0
  launch_configuration      = "${aws_launch_configuration.ec2_node.id}"
  max_size                  = 80
  min_size                  = 0
  default_cooldown          = 60
  health_check_grace_period = 40
  force_delete              = true
  name                      = "${terraform.workspace}-ec2-node${count.index}"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.pub.ids}"]

  tag {
    key                 = "Name"
    value               = "${terraform.workspace}-ec2node"
    propagate_at_launch = true
  }

  tag {
    key                 = "Asggroup"
    value               = "${count.index}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = "${local.tags["Env"]}"
    propagate_at_launch = true
  }
}
