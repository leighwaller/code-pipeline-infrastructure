resource "aws_kms_key" "code_pipeline" {
}

resource "aws_kms_alias" "code_pipeline" {
  name = "alias/code-pipeline-master-key"
  target_key_id = "${aws_kms_key.code_pipeline.arn}"
}
