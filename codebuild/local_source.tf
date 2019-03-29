locals {
  source = {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_organization}/${var.github_repo}.git"
    git_clone_depth = 1
  }
}
