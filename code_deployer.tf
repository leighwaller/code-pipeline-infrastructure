# todo need to tighten up the policies resources

data "aws_iam_policy_document" "deployer" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:PutRolePolicy",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "lambda:AddPermission",
      "lambda:CreateAlias",
      "lambda:CreateEventSourceMapping",
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:GetPolicy",
      "lambda:ListVersionsByFunction",
      "lambda:PublishVersion",
      "lambda:RemovePermission",
      "lambda:UpdateAlias",
      "lambda:UpdateEventSourceMapping",
      "lambda:UpdateFunctionCode",
      "lambda:UpdateFunctionConfiguration",
    ]

    resources = [
      "arn:aws:lambda:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:function:${var.project_name}*",
      "arn:aws:lambda:${data.aws_region.default.name}:${data.aws_caller_identity.default.account_id}:event-source-mappings:*",
    ]
  }

  statement {
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeRegions",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "deployer" {
  name               = "${var.project_name}-deployer"
  assume_role_policy = "${data.aws_iam_policy_document.build_assume_role.json}"
}

resource "aws_iam_role_policy" "deployer" {
  name   = "${var.project_name}-deployer"
  role   = "${aws_iam_role.deployer.id}"
  policy = "${data.aws_iam_policy_document.deployer.json}"
}

resource "aws_iam_role_policy_attachment" "kms_codedeployer" {
  role       = "${aws_iam_role.deployer.id}"
  policy_arn = "${aws_iam_policy.kms.arn}"
}

resource "aws_codebuild_project" "deployer" {
  name = "${var.project_name}-deployer"

  source {
    type = "CODEPIPELINE"
    buildspec = "terraform/buildspec.yml"
  }

  artifacts {
    type = "CODEPIPELINE"
  }


  environment {
    image        = "aws/codebuild/docker:17.09.0"
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    privileged_mode = true

    environment_variable {
      name  = "BUILD_ARTIFACTS_BUCKET"
      value = "291104527402-terraform-state"
    }

//    environment_variable {
//      name  = "ARTIFACT_NAME"
//      value = "${var.artifact_name}"
//    }

    # Add function-specific environment variables here
  }

  service_role  = "${aws_iam_role.deployer.arn}"
  build_timeout = "5" # minutes
}