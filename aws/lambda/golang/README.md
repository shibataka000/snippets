# Lambda Function Sample with Golang and Container

This snippets create two sample lambda functions.

- `ticktack-go` : This function's runtime is `go1.x` .
- `ticktack-go-docker` : This function run on container.

These function are triggered by CloudWatch Events every 5 minutes, and show some information about execution environment.

## Deploy
```bash
make deploy
```

## Crean up
```bash
make clean
```

## References
- [Building Lambda functions with Go - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/lambda-golang.html)
