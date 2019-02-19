resource "aws_launch_configuration" "ec2_node" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.ec2.name}"
  image_id                    = "${local.ami_id}"
  instance_type               = "${local.ec2_instance_type}"
  name_prefix                 = "${terraform.workspace}-asg-launchcnf"
  security_groups             = ["${data.aws_security_group.sec.id}"]

  user_data = "${local.user_data}"

  //user_data = "${data.template_cloudinit_config.cloudinit.rendered}"
  key_name = "${data.terraform_remote_state.base.key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}
