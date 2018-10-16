package test

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestS3WebsiteServesFile(t *testing.T) {
	t.Parallel()

	// Given
	validS3BucketChars := strings.Split("abcdefghijklmnopqrstuvwxyz", "")
	uniqueID := random.RandomString(validS3BucketChars)

	s3BucketName := fmt.Sprintf("terratest-http-example-%s", uniqueID)
	// s3BucketName := "terratest_http_example_3"
	// t.Fatal(s3BucketName)
	awsRegion := "us-east-1" //:= aws.GetRandomRegion(t, nil, nil)

	terraformDir := "../"
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,

		Vars: map[string]interface{}{
			"bucket_name": s3BucketName,
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	// When
	terraform.InitAndApply(t, terraformOptions)

	key := "index.html"
	body := strings.NewReader("This is the body")

	params := &s3manager.UploadInput{
		Bucket: &s3BucketName,
		Key:    &key,
		Body:   body,
	}

	uploader := aws.NewS3Uploader(t, awsRegion)

	_, err := uploader.Upload(params)
	if err != nil {
		t.Fatal(err)
	}

	// Then
	instanceURL := "http://" + terraform.OutputRequired(t, terraformOptions, "url")

	expected := "This is the body"
	maxRetries := 10
	timeBetweenRetries := 5 * time.Second

	http_helper.HttpGetWithRetry(t, instanceURL, 200, expected, maxRetries, timeBetweenRetries)
}
