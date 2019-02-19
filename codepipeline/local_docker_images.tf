locals {
  codebuild_docker_images {
    ubuntu = "aws/codebuild/ubuntu-base:14.04"
    docker = "aws/codebuild/docker:18.09.0"
    golang = "aws/codebuild/golang:1.11"
    nodejs = "aws/codebuild/nodejs:10.14.1"
    python = "	aws/codebuild/python:3.7.1"
    java   = "aws/codebuild/java:openjdk-11"
  }
}
