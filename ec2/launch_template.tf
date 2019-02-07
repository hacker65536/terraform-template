resource "aws_launch_template" "foo" {
  name = "foo"

  /*
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 20
    }
  }
    capacity_reservation_specification {
      capacity_reservation_preference = "open"
    }
  credit_specification {
    cpu_credits = "standard"
  }
  */


  //disable_api_termination = true


  //ebs_optimized = true

  elastic_gpu_specifications {
    type = "test"
  }
  iam_instance_profile {
    name = "test"
  }
  //image_id                             = "ami-test"
  //instance_initiated_shutdown_behavior = "terminate"
  instance_market_options {
    market_type = "spot"
  }
  instance_type = "t2.micro"
  //kernel_id     = "test"
  key_name = "${data.terraform_remote_state.base.key_pair}"

  /*
  license_specification {
    license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  }
  */


  /*
  monitoring {
    enabled = true
  }
  */

  network_interfaces {
    associate_public_ip_address = true
  }
  /*
            placement {
              availability_zone = "us-west-2a"
            }
            */
  //ram_disk_id = "test"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  tag_specifications {
    resource_type = "instance"
    tags          = "${merge(local.tags, map("Name", "${terraform.workspace}-ope"))}"
  }

  // user_data = "${base64encode(...)}"
}
