# Request a Spot fleet
resource "aws_spot_fleet_request" "cheap_compute" {
  iam_fleet_role      = "${aws_iam_role.fleet.arn}"
  spot_price          = "0.5"
  allocation_strategy = "lowestPrice"
  target_capacity     = 2
  valid_until         = "2019-11-04T20:44:20Z"

  // maintain = persisitent  request = one-time
  // spot instance  one-time(default) persistent
  // spot fleet     reqeust  maintain(default)
  fleet_type = "request"

  launch_specification {
    instance_type            = "t2.micro"
    ami                      = "${data.aws_ami.ecs_opt.id}"
    key_name                 = "${data.terraform_remote_state.base.key_pair}"
    spot_price               = "0.4"
    iam_instance_profile_arn = "${aws_iam_instance_profile.ec2.arn}"
    user_data                = "${base64encode(data.template_file.user_data_ecs.rendered)}"

    subnet_id              = "${join(",",data.aws_subnet_ids.pub.ids)}"
    subnet_id              = "${data.aws_subnet_ids.pub.ids[0]}"
    vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]

    tags {
      Name = "${terraform.workspace}-spotfleet"
    }
  }

  launch_specification {
    instance_type            = "t2.small"
    ami                      = "${data.aws_ami.ecs_opt.id}"
    key_name                 = "${data.terraform_remote_state.base.key_pair}"
    spot_price               = "0.4"
    iam_instance_profile_arn = "${aws_iam_instance_profile.ec2.arn}"
    user_data                = "${base64encode(data.template_file.user_data_ecs.rendered)}"

    subnet_id              = "${join(",",data.aws_subnet_ids.pub.ids)}"
    vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]

    tags {
      Name = "${terraform.workspace}-spotfleet"
    }
  }
}
