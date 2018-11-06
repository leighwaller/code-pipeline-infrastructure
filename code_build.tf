resource "aws_iam_role" "codebuild" {
  name = "${var.project_name}-codebuild"
  assume_role_policy = "${data.aws_iam_policy_document.build_assume_role.json}"
}

data "aws_iam_policy_document" "build_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

locals {
  region_account = "${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}"
  log_group_prefix = "arn:aws:logs:${local.region_account}:log-group:/aws/codebuild/${var.project_name}:log-stream"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "${local.log_group_prefix}",
      "${local.log_group_prefix}:*"
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "codecommit:GitPull"
    ]

    resources = [
      "arn:aws:codecommit:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:${var.project_name}"
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = [
      "${aws_s3_bucket.build_artifacts.arn}"
    ]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "kms_codebuild" {
  role       = "${aws_iam_role.codebuild.id}"
  policy_arn = "${aws_iam_policy.kms.arn}"
}

resource "aws_codebuild_project" "default" {
  name = "${var.project_name}"
  description = "${var.project_description}"

  service_role = "${aws_iam_role.codebuild.arn}"
//  badge_enabled = true

  environment {
    compute_type = "${var.build_compute_type}"
    image = "${var.build_image}"
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    buildspec = "${var.build_spec}"
    type      = "${var.build_source_type}"
    location  = "${var.build_source_location}"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  encryption_key = "${aws_kms_alias.code_pipeline.arn}"

  tags {
    Name = "${var.project_name}-code-build"
  }
}
