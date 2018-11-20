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

resource "aws_iam_role_policy_attachment" "pipeline_ec2" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.pipeline_ec2.arn}"
}

resource "aws_iam_policy" "pipeline_ec2" {
  name   = "${var.project_name}-codepipeline-ec2"
  policy = "${data.aws_iam_policy_document.ec2.json}"
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "pipeline_ecs" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.pipeline_ecs.arn}"
}

resource "aws_iam_policy" "pipeline_ecs" {
  name   = "${var.project_name}-codepipeline-ecs"
  policy = "${data.aws_iam_policy_document.ecs.json}"
}

data "aws_iam_policy_document" "ecs" {
  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService"
    ]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "pipeline_iam" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.pipeline_iam.arn}"
}

resource "aws_iam_policy" "pipeline_iam" {
  name   = "${var.project_name}-codepipeline-iam"
  policy = "${data.aws_iam_policy_document.iam.json}"
}

data "aws_iam_policy_document" "iam" {
  statement {
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]
    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "pipeline_s3" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.s3.arn}"
}

resource "aws_iam_role_policy_attachment" "pipeline_kms" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.kms.arn}"
}

resource "aws_iam_role_policy_attachment" "pipeline_build" {
  role       = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.pipeline_build.arn}"
}

resource "aws_iam_policy" "pipeline_build" {
  name   = "${var.project_name}-codepipeline-build"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

data "aws_iam_policy_document" "codebuild" {
  statement {
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = [
      "${aws_codebuild_project.default.id}"
    ]

    effect    = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "pipeline_source" {
  role = "${aws_iam_role.codepipeline.id}"
  policy_arn = "${aws_iam_policy.pipeline_source.arn}"
}

resource "aws_iam_policy" "pipeline_source" {
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
      output_artifacts = ["artifact"]

      configuration {
        ProjectName = "${var.project_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      name = "Deploy"
      owner = "AWS"
      provider = "ECS"
      version = "1"

      input_artifacts = ["artifact"]

      configuration {
        ClusterName = "${var.deploy_target_cluster}"
        ServiceName = "${var.project_name}"
        FileName = "image_definitions.json"
      }
    }
  }

}
