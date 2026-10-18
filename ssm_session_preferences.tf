# Session Manager's regional preferences are this specially-named document, so it applies to the whole account/region
resource "aws_ssm_document" "session_preferences" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Document to hold regional settings for Session Manager"
    sessionType   = "Standard_Stream"
    inputs = {
      s3BucketName                = aws_s3_bucket.session_logs.bucket
      s3KeyPrefix                 = "ssm"
      s3EncryptionEnabled         = true
      cloudWatchLogGroupName      = ""
      cloudWatchEncryptionEnabled = false
      kmsKeyId                    = ""
      idleSessionTimeout          = "20"
      runAsEnabled                = false
      runAsDefaultUser            = ""
    }
  })
}
