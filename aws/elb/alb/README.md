# Sample of Application Load Balancer

## Description
Following resource will be deployed.

- Application Load Balancer
- Nginx web server with AutoScaling Group.

## Demo
```
$ terraform apply
$ curl http://sample-2130495904.ap-northeast-1.elb.amazonaws.com/
172.31.4.47
$ curl http://sample-2130495904.ap-northeast-1.elb.amazonaws.com/
172.31.30.4
```

## Author
[shibataka000](https://github.com/shibataka000)
