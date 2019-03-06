data "template_file" "ssmdoc" {
  template = "${file("ssmdoc.json")}"

  vars {
    go_git = "github.com/--/sql-bench"
  }
}

resource "aws_ssm_document" "ssmdoc" {
  name          = "${terraform.workspace}-sysbench"
  document_type = "Command"

  content = "${data.template_file.ssmdoc.rendered}"
}
