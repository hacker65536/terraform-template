resource "aws_vpc" "vpc" {
  cidr_block = "${local.vpc_cidr_block}"

  #default true
  enable_dns_support = true

  #default false
  enable_dns_hostnames = true

  tags = "${merge(local.tags, 
		map(
			"Name", "${terraform.workspace}-vpc",
		),
	)}"
}
