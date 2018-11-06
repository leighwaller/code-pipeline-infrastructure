# CodeBuild
output "codebuild_project_name" {
  description = "The name of the CodeBuild project"
  value = "${aws_codebuild_project.default.name}"
}

output "codebuild_project_arn" {
  description = "Amazon Resource Name for the CodeBuild project"
  value = "${aws_codebuild_project.default.id}"
}

output "codebuild_role_arn" {
  description = "Amazon Resource Name for the IAM service role given to CodeBuild"
  value = "${aws_iam_role.codebuild.arn}"
}

output "build_artifact_bucket_name" {
  description = "The name of the build artifacts bucket"
  value = "${aws_s3_bucket.build_artifacts.id}"
}

# S3
output "build_artifact_bucket_arn" {
  description = "Amazon Resource Name of the build artifacts bucket"
  value = "${aws_s3_bucket.build_artifacts.arn}"
}

# CodeCommit
output "code_repository_id" {
  description = "This is the id of the CodeCommit repository"
  value = "${aws_codecommit_repository.default.id}"
}

output "code_repository_arn" {
  description = "This is the ARN of the CodeCommit repository"
  value = "${aws_codecommit_repository.default.arn}"
}

output "code_repository_clone_http_url" {
  description = "The URL to use for cloning the repository over HTTPS"
  value = "${aws_codecommit_repository.default.clone_url_http}"
}

output "code_repository_ssh" {
  description = "The URL to use for cloning the repository over SSH"
  value = "${aws_codecommit_repository.default.clone_url_ssh}"
}

# CodePipeline
output "pipeline_id" {
  description = "ID of the code pipeline"
  value = "${aws_codepipeline.default.id}"
}

output "pipeline_arn" {
  description = "Amazon Resource Name of the code pipeline"
  value = "${aws_codepipeline.default.arn}"
}

output "pipeline_role_arn" {
  description = "Amazon Resource Name for the IAM role given to CodePipeline"
  value = "${aws_iam_role.codepipeline.arn}"
}

# KMS
output "kms_key_id" {
  description = "The ID of the KMS key created for encrypting pipeline artifacts"
  value = "${aws_kms_key.code_pipeline.key_id}"
}