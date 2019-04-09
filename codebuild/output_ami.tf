output "ami" {
  value = [
    "amazonlinux=${data.aws_ami.amazonlinux.id}",
    "amazonlinux2=${data.aws_ami.amazonlinux2.id}",
    "cent6=${data.aws_ami.centos6.id}",
    "cent7=${data.aws_ami.centos7.id}",
    "ubuntu18=${data.aws_ami.ubuntu18.id}",
  ]
}
