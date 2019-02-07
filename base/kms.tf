resource "aws_kms_key" "kms" {
  description             = "${terraform.workspace}-kms"
  deletion_window_in_days = 7
  tags                    = "${merge(local.tags, map("Name", "${terraform.workspace}-kms"))}"

  //is_enabled  = true
}

resource "aws_kms_alias" "kms" {
  name          = "alias/${terraform.workspace}-kms"
  target_key_id = "${aws_kms_key.kms.key_id}"
}
