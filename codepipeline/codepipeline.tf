data "aws_kms_alias" "s3kmskey" {
  name = "alias/myKmsKey"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${terraform.workspace}-codepipeline"
  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codepipeline.bucket}"
    type     = "S3"

    encryption_key {
      id   = "${data.aws_kms_alias.s3kmskey.arn}"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["test"]

      configuration = {
        Owner  = "my-organization"
        Repo   = "test"
        Branch = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["test"]
      version         = "1"

      configuration = {
        ProjectName = "test"
      }
    }
  }
}
