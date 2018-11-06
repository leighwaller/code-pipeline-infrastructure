resource "aws_s3_bucket" "build_artifacts" {
  bucket = "${data.aws_caller_identity.default.account_id}-build-artifacts"
  acl = "private"

  tags {
    Name = "build-artifacts-bucket"
  }
}