locals {
  user_data = "${data.template_file.user_data_coreos.rendered}"
}
