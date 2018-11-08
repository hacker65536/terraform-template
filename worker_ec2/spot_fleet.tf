locals {
  spot_price {
    c5.xlarge = "0.4"
  }
}

# Request a Spot fleet
resource "aws_spot_fleet_request" "cheap_compute" {
  count          = 3
  iam_fleet_role = "${aws_iam_role.fleet.arn}"

  //  spot_price          = "0.5"
  allocation_strategy = "lowestPrice"
  target_capacity     = 1
  valid_until         = "2019-11-04T20:44:20Z"

  // maintain = persisitent  request = one-time
  // spot instance  one-time(default) persistent
  // spot fleet     reqeust  maintain(default)
  fleet_type = "request"

  //  terminate_instances                 = true
  terminate_instances_with_expiration = true

  launch_specification {
    instance_type            = "${local.ec2_instance_type}"
    ami                      = "${data.aws_ami.amz2.id}"
    key_name                 = "${data.terraform_remote_state.base.key_pair}"
    spot_price               = "${local.spot_price["${local.ec2_instance_type}"]}"
    iam_instance_profile_arn = "${aws_iam_instance_profile.ec2.arn}"
    user_data                = "${base64encode(data.template_file.user_data_ec2.rendered)}"
    subnet_id                = "${data.aws_subnet_ids.pub.ids[count.index]}"
    vpc_security_group_ids   = ["${data.aws_security_group.sec.id}"]
    weighted_capacity        = 1

    tags = "${merge(local.tags, map("Name", "${terraform.workspace}-ec2node-sf","Asggroup",count.index))}"
  }

  /*
  launch_specification {
    instance_type            = "${local.ec2_instance_type}"
    ami                      = "${data.aws_ami.amz2.id}"
    key_name                 = "${data.terraform_remote_state.base.key_pair}"
    spot_price               = "${local.spot_price["${local.ec2_instance_type}"]}"
    iam_instance_profile_arn = "${aws_iam_instance_profile.ec2.arn}"
    user_data                = "${base64encode(data.template_file.user_data_ec2.rendered)}"
    subnet_id                = "${data.aws_subnet_ids.pub.ids[1]}"
    vpc_security_group_ids   = ["${data.aws_security_group.sec.id}"]
    weighted_capacity        = 1

    tags = "${merge(local.tags, map("Name", "${terraform.workspace}-ec2node-sf"))}"
  }

  launch_specification {
    instance_type            = "${local.ec2_instance_type}"
    ami                      = "${data.aws_ami.amz2.id}"
    key_name                 = "${data.terraform_remote_state.base.key_pair}"
    spot_price               = "0.04"
    iam_instance_profile_arn = "${aws_iam_instance_profile.ec2.arn}"
    user_data                = "${base64encode(data.template_file.user_data_ec2.rendered)}"
    subnet_id                = "${data.aws_subnet_ids.pub.ids[2]}"
    vpc_security_group_ids   = ["${data.aws_security_group.sec.id}"]
    weighted_capacity        = 1

    tags = "${merge(local.tags, map("Name", "${terraform.workspace}-ec2node-sf"))}"
  }
	*/
}
