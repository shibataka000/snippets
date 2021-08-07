FROM golang:1.16 as build
WORKDIR /go/github.com/shibataka000/snippets/aws/lambda/golang/
COPY main.go go.mod go.sum ./
RUN GOOS=linux CGO_ENABLED=0 go build -o app .

FROM public.ecr.aws/lambda/go:1
COPY --from=build /go/github.com/shibataka000/snippets/aws/lambda/golang/app ${LAMBDA_TASK_ROOT}
CMD ["app"]
