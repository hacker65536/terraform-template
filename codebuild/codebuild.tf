resource "aws_codebuild_project" "codebuild" {
  name          = "${terraform.workspace}-codebuild"
  description   = "test_codebuild_project"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild.bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/nodejs:6.3.1"
    type         = "LINUX_CONTAINER"

    environment_variable {
      "name"  = "SOME_KEY1"
      "value" = "SOME_VALUE1"
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

  source = ["${local.source_git}"]

  #source {
  #  type            = "GITHUB"
  #  location        = "https://github.com/hacker65536/ci_test.git"
  #  git_clone_depth = 1
  #}

  vpc_config {
    vpc_id             = "${data.aws_vpc.vpc.id}"
    subnets            = ["${data.aws_subnet_ids.pri_nat.ids}"]
    security_group_ids = ["${data.aws_security_group.sec.id}"]
  }
  tags = "${merge(local.tags,map("Name","${terraform.workspace}-codebuild"))}"
}
