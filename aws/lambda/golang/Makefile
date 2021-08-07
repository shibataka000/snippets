.PHONY: build pack bake push deploy clean

default: deploy

build: main.go
	GOOS=linux CGO_ENABLED=0 go build -o app .

pack: build
	zip app.zip app

bake:
	docker build -t 370106426606.dkr.ecr.ap-northeast-1.amazonaws.com/ticktack-go:latest .

push: bake
	terraform apply -target="aws_ecr_repository.lambda" -auto-approve
	aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 370106426606.dkr.ecr.ap-northeast-1.amazonaws.com
	docker push 370106426606.dkr.ecr.ap-northeast-1.amazonaws.com/ticktack-go:latest

deploy: pack push
	terraform apply -auto-approve

clean: pack
	terraform destroy -auto-approve
	rm -f app app.zip
