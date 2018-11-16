package test

import (
	"fmt"
	"os"
	"regexp"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestApiGatewayReturnsEmptyDynamoDBResponse(t *testing.T) {
	t.Parallel()

	awsRegion := "us-east-1" //:= aws.GetRandomRegion(t, nil, nil)

	uniqueID := random.UniqueId()
	tableName := fmt.Sprintf("terratest-dynamodb-table-%s", uniqueID)

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion)},
	)

	// Create DynamoDB client
	svc := dynamodb.New(sess)

	input := &dynamodb.CreateTableInput{
		AttributeDefinitions: []*dynamodb.AttributeDefinition{
			{
				AttributeName: aws.String("testId"),
				AttributeType: aws.String("S"),
			},
		},
		KeySchema: []*dynamodb.KeySchemaElement{
			{
				AttributeName: aws.String("testId"),
				KeyType:       aws.String("HASH"),
			},
		},
		ProvisionedThroughput: &dynamodb.ProvisionedThroughput{
			ReadCapacityUnits:  aws.Int64(1),
			WriteCapacityUnits: aws.Int64(1),
		},
		TableName: aws.String(tableName),
	}

	deleteTableInput := &dynamodb.DeleteTableInput{
		TableName: aws.String(tableName),
	}

	tableOutput, err := svc.CreateTable(input)

	if err != nil {
		fmt.Println("Got error calling CreateTable:")
		fmt.Println(err.Error())
		os.Exit(1)
	}

	tableArn := *tableOutput.TableDescription.TableArn

	// Given

	requestTemplate := fmt.Sprintf(`{
        \"TableName\": \"%s\",
        \"KeyConditionExpression\": \"testId = :v1\",
        \"ExpressionAttributeValues\": {
            \":v1\": {
                \"S\": \"$input.params('testId')\"
            }
        }
    }`, tableName)
	re := regexp.MustCompile(`\r?\n?`)
	requestTemplate = re.ReplaceAllString(requestTemplate, "")

	namespace := fmt.Sprintf("terratest-dynamodb-test-%s", uniqueID)

	terraformOptions := &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"namespace":        namespace,
			"root_path":        "test",
			"table_arn":        tableArn,
			"path_part":        "{testId}",
			"request_template": requestTemplate,
			"map_domain_name":  false,
			"domain_name":      "",
		},

		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": awsRegion,
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	defer svc.DeleteTable(deleteTableInput)

	// When
	terraform.InitAndApply(t, terraformOptions)

	// Then
	instanceURL := terraform.OutputRequired(t, terraformOptions, "url")
	instanceURL = fmt.Sprintf("%s/test-value", instanceURL)

	expected := "{\"Count\":0,\"Items\":[],\"ScannedCount\":0}"
	maxRetries := 10
	timeBetweenRetries := 5 * time.Second

	http_helper.HttpGetWithRetry(t, instanceURL, 200, expected, maxRetries, timeBetweenRetries)
}
