locals {
  container_img = "${data.aws_ecr_repository.ecr.repository_url}"
}

resource "aws_codebuild_project" "codebuild" {
  name          = "${terraform.workspace}-codebuild"
  description   = "${terraform.workspace}-description"
  build_timeout = "50"
  service_role  = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "NO_ARTIFACTS"

    /*
    type           = "S3"
    namespace_type = "BUILD_ID"
    location       = "${aws_s3_bucket.codebuild.bucket}"
    */
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild.bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "${local.container_img}:latest"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "PACKER_VERSION"
      "value" = "1.2.2"
    }

    environment_variable {
      "name"  = "ANSIBLE_VERSION"
      "value" = "2.5.0"
    }

    environment_variable {
      "name"  = "SUBNET_ID"
      "value" = "${data.aws_subnet.pub.*.id[0]}"
    }

    environment_variable {
      "name"  = "VPC_ID"
      "value" = "${data.aws_vpc.vpc.id}"
    }

    environment_variable {
      "name"  = "KEY_PAIR"
      "value" = "${data.terraform_remote_state.base.key_pair}"
    }

    environment_variable {
      "name"  = "SECURITY_GROUP_ID"
      "value" = "${data.aws_security_group.sec.id}"
    }

    /*
    environment_variable {
      "name"  = "SOME_KEY2"
      "value" = "SOME_VALUE2"
      "type"  = "PARAMETER_STORE"
    }
    */
  }

  badge_enabled = true

  source = ["${local.source}"]

  /*
    source {
      type            = "GITHUB"
      location        = "https://github.com/hacker65536/ci_test.git"
      git_clone_depth = 1
    }
  */

  vpc_config {
    vpc_id             = "${data.aws_vpc.vpc.id}"
    subnets            = ["${data.aws_subnet_ids.pri_nat.ids}"]
    security_group_ids = ["${data.aws_security_group.sec.id}"]
  }
  tags = "${merge(local.tags,map("Name","${terraform.workspace}-codebuild"))}"
}
