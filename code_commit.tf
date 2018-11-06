resource "aws_codecommit_repository" "default" {
  repository_name = "${var.project_name}"
  description = "${var.project_description}"
  default_branch = "${var.build_default_branch}"
}
