#data "template_file" "init" {
#  template = "${file("user_data.sh")}"
#}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.amz2.id}"
  instance_type               = "t2.micro"
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

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-bastion"),map("Backup-Generation","0"))}"
}

resource "aws_eip" "bastion" {
  vpc      = true
  instance = "${aws_instance.bastion.id}"
  tags     = "${merge(local.tags, map("Name", "${terraform.workspace}-bastion-ip"))}"
}

resource "aws_instance" "demo" {
  ami                    = "${data.aws_ami.amz2.id}"
  instance_type          = "t2.micro"
  key_name               = "${data.terraform_remote_state.base.key_pair}"
  subnet_id              = "${data.aws_subnet_ids.pri_nat.ids[0]}"
  vpc_security_group_ids = ["${data.aws_security_group.sec.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.ec2.name}"
  monitoring             = true

  //user_data = "${data.template_file.init.rendered}"

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-demo"),map("Backup-Generation","0"))}"
}
