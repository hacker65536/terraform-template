/*
data "template_file" "user_data_ec2_sysbench" {
  template = "${file("user_data_ec2_sysbench.sh")}"

  vars {}

  //  ecs_cluster = "${aws_ecs_cluster.cluster.name}"  
  //password = "foobarbaz"  
  // list     = "${join("\n",data.terraform_remote_state.rds.mysql_addresses)}"
}
*/

data "template_file" "user_data_coreos" {
  template = "${file("user_data_coreos.yml")}"

  /*
  vars {
  }
  */
  //token = "159618581048d1d24b6384ea9e2cf68e"

  //  ecs_cluster = "${aws_ecs_cluster.cluster.name}"  
  //password = "foobarbaz"  
  // list     = "${join("\n",data.terraform_remote_state.rds.mysql_addresses)}"
}
