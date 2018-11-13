data "template_file" "user_data_ec2" {
  template = "${file("user_data_ec2.sh")}"

  vars {
    //  ecs_cluster = "${aws_ecs_cluster.cluster.name}"
    password = "foobarbaz"
  }
}

resource "aws_launch_configuration" "ec2_node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.ec2.name}"
  image_id                    = "${data.aws_ami.amz2.id}"
  instance_type               = "${local.ec2_instance_type}"
  name_prefix                 = "${terraform.workspace}-asg-launchcnf"
  security_groups             = ["${data.aws_security_group.sec.id}"]
  user_data_base64            = "${base64encode(data.template_file.user_data_ec2.rendered)}"
  key_name                    = "${data.terraform_remote_state.base.key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}
