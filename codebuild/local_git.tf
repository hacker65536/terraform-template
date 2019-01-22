locals {
  source_git {
    type                = "GITHUB"
    location            = "https://github.com/hacker65536/ci_test.git"
    git_clone_depth     = 1
    report_build_status = true
  }
}
