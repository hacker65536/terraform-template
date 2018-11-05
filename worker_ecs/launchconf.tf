data "template_file" "user_data_ecs" {
  template = "${file("user_data_ecs.sh")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.cluster.name}"
  }
}

locals {
  ec2_instance_type = "c4.large"
}

resource "aws_launch_configuration" "ecs_node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.ec2.name}"
  image_id                    = "${data.aws_ami.ecs_opt.id}"
  instance_type               = "${local.ec2_instance_type}"
  name_prefix                 = "${terraform.workspace}-asg-launchcnf"
  security_groups             = ["${data.aws_security_group.sec.id}"]
  user_data_base64            = "${base64encode(data.template_file.user_data_ecs.rendered)}"
  key_name                    = "${data.terraform_remote_state.base.key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}
