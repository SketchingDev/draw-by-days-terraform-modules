output "bucket_name" {
    value = "${aws_s3_bucket.website.id}"
}

output "url" {
    value = "${aws_s3_bucket.website.website_endpoint}"
}

output "hosted_zone_ids" {
    sensitive = true,
    value = "${aws_s3_bucket.website.hosted_zone_id}"
}
