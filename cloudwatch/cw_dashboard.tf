data "template_file" "cwdbrds" {
  template = "${file("${path.cwd}/cwdb.json")}"

  vars {
    prefix = "${terraform.workspace}"
    region = "${data.aws_region.region.name}"
  }
}

resource "aws_cloudwatch_dashboard" "cwdbrds" {
  dashboard_name = "${terraform.workspace}-dashboard"
  dashboard_body = "${data.template_file.cwdbrds.rendered}"
}
