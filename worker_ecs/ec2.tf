#data "template_file" "init" {
#  template = "${file("user_data.sh")}"
#}

resource "aws_instance" "master" {
  ami                         = "${data.aws_ami.amz2.id}"
  instance_type               = "c4.xlarge"
  key_name                    = "${data.terraform_remote_state.base.key_pair}"
  subnet_id                   = "${data.aws_subnet_ids.pub.ids[0]}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${data.aws_security_group.sec.id}"]
  iam_instance_profile        = "${aws_iam_instance_profile.ec2.name}"

  #  ebs_optimized               = true
  /*
    root_block_device {
      volume_type = "gp2"
      volume_size = "1000"
    }
  	*/
  //user_data = "${data.template_file.init.rendered}"

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-locust-master"),map("Backup-Generation","0"))}"
}

resource "aws_eip" "eip" {
  vpc      = true
  instance = "${aws_instance.master.id}"
  tags     = "${merge(local.tags, map("Name", "${terraform.workspace}-locust-master-ip"))}"
}
