
resource "aws_cloudwatch_event_rule" "pipeline_trigger" {
  name = "${var.project_name}-codepipeline-trigger"
  description = "Triggers the code pipeline to run when the state changes in our CodeCommit repository."

  event_pattern = "${data.template_file.event_pattern.rendered}"
}

data "template_file" "event_pattern" {
  template = "${file("templates/codecommit_event_pattern.json.tpl")}"

  vars {
    repository_arn = "${aws_codecommit_repository.default.arn}"
    branch_name = "${var.build_default_branch}"
  }
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  target_id = "${var.project_name}-pipeline-target"
  rule      = "${aws_cloudwatch_event_rule.pipeline_trigger.name}"
  arn       = "${aws_codepipeline.default.arn}"
  role_arn  = "${aws_iam_role.cloudwatch_trigger.arn}"
}

resource "aws_iam_role" "cloudwatch_trigger" {
  name = "${var.project_name}-cloudwatch-trigger-pipeline"
  assume_role_policy = "${data.aws_iam_policy_document.cloudwatch_assume_role.json}"
}

data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com"
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "codepipeline_execute" {
  role       = "${aws_iam_role.cloudwatch_trigger.id}"
  policy_arn = "${aws_iam_policy.codepipeline_execute.arn}"
}

resource "aws_iam_policy" "codepipeline_execute" {
  name   = "${var.project_name}-codepipeline-execute"
  policy = "${data.aws_iam_policy_document.codepipeline_execute.json}"
}

data "aws_iam_policy_document" "codepipeline_execute" {
  statement {
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = ["${aws_codepipeline.default.arn}"]

    effect = "Allow"
  }
}