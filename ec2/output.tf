output "rdss" {
  value = "${length(data.terraform_remote_state.rds.mysql_addresses)}"
}
