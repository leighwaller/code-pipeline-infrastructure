resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-codepipeline"
  assume_role_policy = "${data.aws_iam_policy_document.pipeline_assume_role.json}"
}

data "aws_iam_policy_document" "pipeline_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.codepipeline_policy.arn}"
}

resource "aws_iam_policy" "codepipeline_policy" {
  name   = "${var.project_name}-codepipeline"
  policy = "${data.aws_iam_policy_document.codepipeline.json}"
}

data "aws_iam_policy_document" "codepipeline" {
  statement {
    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_policy" "s3" {
  name   = "${var.project_name}-codepipeline-s3"
  policy = "${data.aws_iam_policy_document.s3.json}"
}

# todo tighten this up
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

resource "aws_iam_role_policy_attachment" "kms_codepipeline" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.kms.arn}"
}

resource "aws_iam_policy" "kms" {
  name   = "${var.project_name}-kms-policy"
  policy = "${data.aws_iam_policy_document.kms.json}"
}

data "aws_iam_policy_document" "kms" {
  statement {
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]

    resources = ["${aws_kms_key.code_pipeline.arn}"]

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline_build" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.codepipeline_build.arn}"
}

resource "aws_iam_policy" "codepipeline_build" {
  name   = "${var.project_name}-codepipeline-build"
  policy = "${data.aws_iam_policy_document.codepipeline_build.json}"
}

data "aws_iam_policy_document" "codepipeline_build" {
  statement {
    actions = [
      "codebuild:*",
    ]

    resources = ["${aws_codebuild_project.default.id}"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline_source" {
  role = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.codepipeline_source.arn}"
}

resource "aws_iam_policy" "codepipeline_source" {
  name = "${var.project_name}-codepipeline-source"
  policy = "${data.aws_iam_policy_document.codepipeline_source.json}"
}

data "aws_iam_policy_document" "codepipeline_source" {
  statement {
    actions = [
      "codecommit:*",
    ]

    resources = ["${aws_codecommit_repository.default.arn}"]
    effect    = "Allow"
  }
}

resource "aws_codepipeline" "default" {
  name = "${var.project_name}"

  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.build_artifacts.bucket}"
    type = "S3"

    encryption_key {
      id = "${aws_kms_alias.code_pipeline.arn}"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      name = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"

      output_artifacts = ["source"]

      configuration {
        RepositoryName = "${var.project_name}"
        BranchName = "${var.build_default_branch}"
        PollForSourceChanges = false
      }
    }

  }

  stage {
    name = "Build"

    action {
      category = "Build"
      name = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"

      input_artifacts = ["source"]
      output_artifacts = ["package"]

      configuration {
        ProjectName = "${var.project_name}"
      }
    }

  }

}

# todo add CloudWatch event to auto start pipeline on code commits