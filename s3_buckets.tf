resource "aws_s3_bucket" "build_artifacts" {
  bucket = "${data.aws_caller_identity.default.account_id}-build-artifacts"
  acl = "private"

  tags {
    Name = "build-artifacts-bucket"
  }
}

resource "aws_iam_policy" "s3" {
  name   = "${var.project_name}-codepipeline-s3"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

data "aws_iam_policy_document" "s3" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.build_artifacts.arn}",
      "${aws_s3_bucket.build_artifacts.arn}/*",
    ]

    effect = "Allow"
  }
}