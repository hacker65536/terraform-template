locals {
  //ami_id = "${data.aws_ami.amz2.id}"

  ami_id = "${data.aws_ami.coreos.id}"
}
