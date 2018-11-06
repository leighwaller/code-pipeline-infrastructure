variable "project_name" {
  description = "The name of the repository/project being built by this pipeline."
}

variable "project_description" {
  description = "Short description of the repository/project being built by this pipeline."
  default = ""
}

variable "build_compute_type" {
  description = "Compute type for the instance used to run builds"
  default = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "Docker image id used for the build environment"
  default = "ubuntu/docker/17.09.0"
}

variable "build_spec" {
  description = "Override the buildspec file to be used in CodeBuild. Defaults to buildspec.yml in the project root directory."
  default = ""
}

variable "source_type" {
  description = "Type of repository that contains the source code to be built. Valid values for this parameter are: CODECOMMIT, CODEPIPELINE, GITHUB, GITHUB_ENTERPRISE, BITBUCKET or S3."
  default = "CODEPIPELINE"
}

variable "source_location" {
  description = "Override the source location. Defaults to the project root directory"
  default = ""
}

variable "default_branch" {
  description = "Default git branch used by CodeCommit"
  default = "develop"
}