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

resource "aws_iam_role_policy_attachment" "codebuild_logstream" {
  role       = "${aws_iam_role.codebuild.id}"
  policy_arn = "${aws_iam_policy.logstream.arn}"
}

resource "aws_iam_policy" "logstream" {
  name   = "${var.project_name}-logstream"
  policy = "${data.aws_iam_policy_document.logstream.json}"
}

data "aws_iam_policy_document" "logstream" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]

    effect = "Allow"
  }
}

data "aws_iam_policy" "ecr_full" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "codebuild_ecr" {
  role       = "${aws_iam_role.codebuild.id}"
  policy_arn = "${data.aws_iam_policy.ecr_full.arn}"
}

resource "aws_iam_role_policy_attachment" "s3_build" {
  role       = "${aws_iam_role.codebuild.id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
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
    type      = "CODEPIPELINE"
    location  = "${var.build_source_location}"
    buildspec = "${var.build_spec}"
  }

  artifacts {
    type = "CODEPIPELINE"
    location = "${aws_s3_bucket.build_artifacts.id}"
    path = "${var.project_name}"
  }

  encryption_key = "${aws_kms_alias.code_pipeline.arn}"

  tags {
    Name = "${var.project_name}-code-build"
  }
}
