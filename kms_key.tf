resource "aws_kms_key" "code_pipeline" {
}

resource "aws_kms_alias" "code_pipeline" {
  name = "alias/code-pipeline-master-key"
  target_key_id = "${aws_kms_key.code_pipeline.arn}"
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