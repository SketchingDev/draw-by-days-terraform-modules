package test

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformHttpExample(t *testing.T) {
	t.Parallel()

	// Given
	uniqueID := random.UniqueId()
	namespace := fmt.Sprintf("terratest-http-example-%s", uniqueID)

	awsRegion := "us-east-1" //:= aws.GetRandomRegion(t, nil, nil)

	terraformDir := "../"
	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,

		Vars: map[string]interface{}{
			"namespace":       namespace,
			"stage_name":      "test",
			"lambda_filename": terraformDir + "/test/test-handler.zip",
			"lambda_handler":  "main.handler",
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	// When
	terraform.InitAndApply(t, terraformOptions)

	// Then
	instanceURL := terraform.OutputRequired(t, terraformOptions, "url")

	expected := "Hello world"
	maxRetries := 10
	timeBetweenRetries := 5 * time.Second

	http_helper.HttpGetWithRetry(t, instanceURL, 200, expected, maxRetries, timeBetweenRetries)
}
