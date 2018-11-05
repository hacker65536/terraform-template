resource "aws_iam_role" "rds_enhanced_monitoring_role" {
  name               = "${terraform.workspace}-rds-enhanced-monitoring-role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_monitoring_rds.json}"
}

locals {
  enhancedpolices = [
    "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole",
  ]
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring_role" {
  count      = "${length(local.enhancedpolices)}"
  role       = "${aws_iam_role.rds_enhanced_monitoring_role.name}"
  policy_arn = "${element(local.enhancedpolices,count.index)}"
}
