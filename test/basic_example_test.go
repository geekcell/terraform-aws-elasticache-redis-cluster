package test

import (
	"os"
	"testing"

	TTAWS "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/terraform"

	"github.com/stretchr/testify/assert"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/elasticache"
)

func TestTerraformBasicExample(t *testing.T) {
	clusterName := "terraform-test-cluster-" + GetShortId()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/basic-example",
		Vars: map[string]interface{}{
			"name": clusterName,
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	primary_endpoint_address := terraform.Output(t, terraformOptions, "primary_endpoint_address")
	assert.NotEmpty(t, primary_endpoint_address)

	reader_endpoint_address := terraform.Output(t, terraformOptions, "reader_endpoint_address")
	assert.NotEmpty(t, reader_endpoint_address)

	sess, err := NewSession(os.Getenv("AWS_REGION"))
	assert.NoError(t, err)

	client := elasticache.New(sess)

	input := &elasticache.DescribeReplicationGroupsInput{ReplicationGroupId: &clusterName}
	output, err := client.DescribeReplicationGroups(input)
	assert.NoError(t, err)

	assert.Equal(t, 1, len(output.ReplicationGroups))
	assert.Equal(t, clusterName, aws.StringValue(output.ReplicationGroups[0].ReplicationGroupId))

	assert.Equal(t, "cache.t4g.micro", aws.StringValue(output.ReplicationGroups[0].CacheNodeType))
	assert.True(t, aws.BoolValue(output.ReplicationGroups[0].AtRestEncryptionEnabled))
	assert.True(t, aws.BoolValue(output.ReplicationGroups[0].TransitEncryptionEnabled))
	assert.Equal(t, "required", aws.StringValue(output.ReplicationGroups[0].TransitEncryptionMode))
	assert.True(t, aws.BoolValue(output.ReplicationGroups[0].AuthTokenEnabled))
	assert.Equal(t, "enabled", aws.StringValue(output.ReplicationGroups[0].MultiAZ))
	assert.Equal(t, "enabled", aws.StringValue(output.ReplicationGroups[0].AutomaticFailover))

	assert.NotEmpty(t, aws.StringValue(output.ReplicationGroups[0].SnapshotWindow))
	assert.Equal(t, int64(7), aws.Int64Value(output.ReplicationGroups[0].SnapshotRetentionLimit))
}

func NewSession(region string) (*session.Session, error) {
	sess, err := TTAWS.NewAuthenticatedSession(region)
	if err != nil {
		return nil, err
	}

	return sess, nil
}

func GetShortId() string {
	githubSha := os.Getenv("GITHUB_SHA")
	if len(githubSha) >= 7 {
		return githubSha[0:6]
	}

	return "local"
}
