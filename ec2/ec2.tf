#data "template_file" "init" {
#  template = "${file("user_data.sh")}"
#}

data "template_file" "user_data_ec2" {
  template = "${file("user_data_ec2.sh")}"

  vars {
    //  ecs_cluster = "${aws_ecs_cluster.cluster.name}"
    password = "foobarbaz"
    list     = "${join("\n",data.terraform_remote_state.rds.mysql_addresses)}"
  }
}

//resource "aws_instance" "bastion" {
//  ami                         = "${data.aws_ami.amz2.id}"
//  instance_type               = "t2.micro"
//  key_name                    = "${data.terraform_remote_state.base.key_pair}"
//  subnet_id                   = "${data.aws_subnet_ids.pub.ids[0]}"
//  associate_public_ip_address = true
//  vpc_security_group_ids      = ["${data.aws_security_group.sec.id}"]
//  iam_instance_profile        = "${aws_iam_instance_profile.ec2.name}"
//  tags                        = "${merge(local.tags, map("Name", "${terraform.workspace}-bastion"),map("Backup-Generation","0"))}"
//
//  #  ebs_optimized               = true
//  /*
//    root_block_device {
//      volume_type = "gp2"
//      volume_size = "1000"
//    }
//  	*/
//}
//
//resource "aws_eip" "bastion" {
//  vpc      = true
//  instance = "${aws_instance.bastion.id}"
//  tags     = "${merge(local.tags, map("Name", "${terraform.workspace}-bastion-ip"))}"
//}

locals {
  ec2_instance_tyeps = [
    //    "t2.micro",
    "c4.large",
  ]

  //    "c4.xlarge",
  //"c5.2xlarge",
}

resource "aws_instance" "demo" {
  //count                  = "${length(local.ec2_instance_tyeps)}"
  count                  = "1"
  ami                    = "${data.aws_ami.amz2.id}"
  instance_type          = "${element(local.ec2_instance_tyeps,count.index)}"
  key_name               = "${data.terraform_remote_state.base.key_pair}"
  subnet_id              = "${data.aws_subnet_ids.pub.ids[count.index % length(data.aws_availability_zones.azs.names)]}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.ec2.name}"
  user_data_base64       = "${base64encode(data.template_file.user_data_ec2.rendered)}"
  monitoring             = true
  tags                   = "${merge(local.tags, map("Name", "${terraform.workspace}-demo"),map("Backup-Generation","0"))}"
}

/*
output "userdata" {
  value = "${data.template_file.user_data_ec2.rendered}"
}
*/
output "demoips" {
  value = "${aws_instance.demo.*.public_ip}"
}
