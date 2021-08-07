package main

import (
	"context"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/lambdacontext"
)

func init() {
	log.Println("Initializing")
}

func dump(ctx context.Context, event events.CloudWatchEvent) {
	log.Printf("FunctionName: %s\n", lambdacontext.FunctionName)
	log.Printf("FunctionVersion: %s\n", lambdacontext.FunctionVersion)
	log.Printf("MemoryLimitInMb: %d\n", lambdacontext.MemoryLimitInMB)
	log.Printf("LogGroupName: %s\n", lambdacontext.LogGroupName)
	log.Printf("LogStreamName: %s\n", lambdacontext.LogStreamName)

	deadline, _ := ctx.Deadline()
	log.Printf("Deadline: %v\n", deadline)

	lc, _ := lambdacontext.FromContext(ctx)
	log.Printf("InvokedFunctionArn: %s\n", lc.InvokedFunctionArn)
	log.Printf("AwsRequestID: %s\n", lc.AwsRequestID)
	log.Printf("Identity: %v\n", lc.Identity)
	log.Printf("ClientContext: %v\n", lc.ClientContext)

	log.Printf("event.AccountID: %v\n", event.AccountID)
	log.Printf("event.Detail: %v\n", event.Detail)
	log.Printf("event.DetailType: %v\n", event.DetailType)
	log.Printf("event.ID: %v\n", event.ID)
	log.Printf("event.Region: %v\n", event.Region)
	log.Printf("event.Resources: %v\n", event.Resources)
	log.Printf("event.Source: %v\n", event.Source)
	log.Printf("event.Time: %v\n", event.Time)
	log.Printf("event.Version: %v\n", event.Version)
	fmt.Printf("event: %v\n", event)
}

func LambdaHandler(ctx context.Context, event events.CloudWatchEvent) (string, error) {
	dump(ctx, event)
	return "", nil
}

func main() {
	lambda.Start(LambdaHandler)
}
