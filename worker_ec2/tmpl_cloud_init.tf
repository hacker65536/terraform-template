data "template_cloudinit_config" "cloudinit" {
  gzip          = false
  base64_encode = false

  # Main cloud-config configuration file.
  part {
    //filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = "${data.template_file.user_data_coreos.rendered}"
  }

  /*
  part {
    content_type = "text/x-shellscript"
    content      = "baz"
  }

  part {
    content_type = "text/x-shellscript"
    content      = "ffbaz"
  }
  */
}

output "tmp" {
  value = "${data.template_file.user_data_coreos.rendered}"
}
