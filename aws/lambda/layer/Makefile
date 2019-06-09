.PHONY: default package deploy destroy

default: deploy

package:
	zip -rq layer.zip python/
	zip -rq function.zip lambda_handler.py

deploy: package
	terraform apply

destroy:
	terraform destroy
