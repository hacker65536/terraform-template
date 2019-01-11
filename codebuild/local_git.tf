locals {
  source_git {
    type            = "GITHUB"
    location        = "https://github.com/hacker65536/ci_test.git"
    git_clone_depth = 1

    auth {
      type     = "OAUTH"
      resource = "3b68b976e1f15a005f0b166907275008d29fa645"
    }
  }
}
