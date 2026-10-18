data "aws_iam_policy_document" "jumphost_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jumphost" {
  name               = "${var.name}-jumphost"
  assume_role_policy = data.aws_iam_policy_document.jumphost_assume_role.json
}

resource "aws_iam_role_policy_attachment" "jumphost_ssm" {
  role       = aws_iam_role.jumphost.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jumphost" {
  name = "${var.name}-jumphost"
  role = aws_iam_role.jumphost.name
}

data "aws_iam_policy_document" "jumphost_session_logs" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.session_logs.arn}/ssm/*"]
  }

  statement {
    actions   = ["s3:GetEncryptionConfiguration"]
    resources = [aws_s3_bucket.session_logs.arn]
  }
}

resource "aws_iam_policy" "jumphost_session_logs" {
  name   = "${var.name}-jumphost-session-logs"
  policy = data.aws_iam_policy_document.jumphost_session_logs.json
}

resource "aws_iam_role_policy_attachment" "jumphost_session_logs" {
  role       = aws_iam_role.jumphost.name
  policy_arn = aws_iam_policy.jumphost_session_logs.arn
}
