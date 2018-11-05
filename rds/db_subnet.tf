resource "aws_db_subnet_group" "subnet" {
  name       = "${terraform.workspace}-db-subnet"
  subnet_ids = ["${data.aws_subnet_ids.pri.ids}"]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-db-subnet"))}"
}
