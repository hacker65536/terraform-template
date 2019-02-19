


base
--
- vpc
- subunet (public , private)
- subnet (public(natgw) , private(nat)) (option)
- route table /associate
- securitygroup
- internet gateway
- dhcp option set
- key pair
- nat gateway (option)
- vpc endpoint (option)


### subnet

data resourceでフィルターして利用できるようにsubnet毎の役割をタグ `tag:SubnetRole`をつける
```HCL
resource "aws_subnet" "pri" {
  count                   = "${local.multi_azs}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block,8,count.index + local.multi_azs)}"
  availability_zone       = "${data.aws_availability_zones.azs.names[count.index % local.multi_azs]}"
  map_public_ip_on_launch = false

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-pri","SubnetRole","pri"))}"
}
```
```HCL
data "aws_subnet_ids" "pri" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags {
    SubnetRole = "pri"
  }
}
```
```HCL
resource "aws_db_subnet_group" "subnet" {
  name       = "${terraform.workspace}-db-subnet"
  subnet_ids = ["${data.aws_subnet_ids.pri.ids}"]

  tags = "${merge(local.tags, map("Name", "${terraform.workspace}-db-subnet"))}"
}
```

rds
--
- db_instance
- db_paramter_group
- db_option_group
- rds_cluster
- rds_cluster_instance
- rds_cluster_parameter_group
