output "bucket_name" {
    value = "${aws_s3_bucket.website.id}"
}

output "url" {
    value = "${aws_s3_bucket.website.website_endpoint}"
}

output "domain" {
    value = "${aws_s3_bucket.website.website_domain}"
}

output "hosted_zone_id" {
    sensitive = true,
    value = "${aws_s3_bucket.website.hosted_zone_id}"
}
