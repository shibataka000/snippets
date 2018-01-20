package main

import (
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/batch"
)

const (
	computeEnvironmentName = "C4OnDemand01"
)

func createComputeEnvrionment() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := batch.New(sess)

	input := &batch.CreateComputeEnvironmentInput{
		ComputeEnvironmentName: aws.String(computeEnvironmentName),
		ComputeResources: &batch.ComputeResource{
			DesiredvCpus: aws.Int64(1),
			Ec2KeyPair:   aws.String("id_rsa"),
			InstanceRole: aws.String("arn:aws:iam::370106426606:instance-profile/ecsInstanceRole"),
			InstanceTypes: []*string{
				aws.String("c4.large"),
				aws.String("c4.xlarge"),
				aws.String("c4.2xlarge"),
				aws.String("c4.4xlarge"),
				aws.String("c4.8xlarge"),
			},
			MaxvCpus: aws.Int64(128),
			MinvCpus: aws.Int64(0),
			SecurityGroupIds: []*string{
				aws.String("sg-5a03023f"),
			},
			Subnets: []*string{
				aws.String("subnet-ba2ca7e3"),
				aws.String("subnet-c44132b3"),
			},
			Tags: map[string]*string{
				"Name": aws.String("Batch Instance - C4OnDemand"),
			},
			Type: aws.String("EC2"),
		},
		ServiceRole: aws.String("arn:aws:iam::370106426606:role/service-role/AWSBatchServiceRole"),
		State:       aws.String("ENABLED"),
		Type:        aws.String("MANAGED"),
	}

	result, err := svc.CreateComputeEnvironment(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case batch.ErrCodeClientException:
				fmt.Println(batch.ErrCodeClientException, aerr.Error())
			case batch.ErrCodeServerException:
				fmt.Println(batch.ErrCodeServerException, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	waitComputeEnvironmentStatusValid()

	fmt.Println(result)
}

func waitComputeEnvironmentStatusValid() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := batch.New(sess)

	for {
		input := &batch.DescribeComputeEnvironmentsInput{
			ComputeEnvironments: []*string{
				aws.String(computeEnvironmentName),
			},
		}

		result, err := svc.DescribeComputeEnvironments(input)
		if err != nil {
			if aerr, ok := err.(awserr.Error); ok {
				switch aerr.Code() {
				case batch.ErrCodeClientException:
					fmt.Println(batch.ErrCodeClientException, aerr.Error())
				case batch.ErrCodeServerException:
					fmt.Println(batch.ErrCodeServerException, aerr.Error())
				default:
					fmt.Println(aerr.Error())
				}
			} else {
				// Print the error, cast err to awserr.Error to get the Code and
				// Message from an error.
				fmt.Println(err.Error())
			}
			return
		}

		if len(result.ComputeEnvironments) == 1 {
			if *(result.ComputeEnvironments[0].Status) == "VALID" {
				break
			} else {
				time.Sleep(1 * time.Second)
			}
		} else {
			fmt.Println("err")
			return
		}
	}
}

func updateComputeEnvironment() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := batch.New(sess)

	input := &batch.UpdateComputeEnvironmentInput{
		ComputeEnvironment: aws.String(computeEnvironmentName),
		// State:              aws.String("DISABLED"),
		ComputeResources: &batch.ComputeResourceUpdate{
			DesiredvCpus: aws.Int64(1),
			MaxvCpus:     aws.Int64(64),
			MinvCpus:     aws.Int64(0),
		},
	}

	result, err := svc.UpdateComputeEnvironment(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case batch.ErrCodeClientException:
				fmt.Println(batch.ErrCodeClientException, aerr.Error())
			case batch.ErrCodeServerException:
				fmt.Println(batch.ErrCodeServerException, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	waitComputeEnvironmentStatusValid()

	fmt.Println(result)
}

func disableComputeEnvironment() {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := batch.New(sess)

	input := &batch.UpdateComputeEnvironmentInput{
		ComputeEnvironment: aws.String(computeEnvironmentName),
		State:              aws.String("DISABLED"),
	}

	result, err := svc.UpdateComputeEnvironment(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case batch.ErrCodeClientException:
				fmt.Println(batch.ErrCodeClientException, aerr.Error())
			case batch.ErrCodeServerException:
				fmt.Println(batch.ErrCodeServerException, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	waitComputeEnvironmentStatusValid()

	fmt.Println(result)
}

func deleteComputeEnvironment() {
	disableComputeEnvironment()

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := batch.New(sess)

	input := &batch.DeleteComputeEnvironmentInput{
		ComputeEnvironment: aws.String(computeEnvironmentName),
	}

	result, err := svc.DeleteComputeEnvironment(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case batch.ErrCodeClientException:
				fmt.Println(batch.ErrCodeClientException, aerr.Error())
			case batch.ErrCodeServerException:
				fmt.Println(batch.ErrCodeServerException, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return
	}

	fmt.Println(result)
}

func main() {
	createComputeEnvrionment()
	updateComputeEnvironment()
	deleteComputeEnvironment()
}
