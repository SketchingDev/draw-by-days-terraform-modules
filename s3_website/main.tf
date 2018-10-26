resource "aws_s3_bucket" "website" {
  bucket = "${var.name}"
  acl = "public-read"
  policy = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.name}/*",
      "Principal": "*"
    }
  ]
}
EOF
  website {
    index_document = "${var.index_document}"
    error_document = "${var.error_document}"
  }
  force_destroy = true
}
