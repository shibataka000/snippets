# mesos
Apache Mesos Getting Started.
See [Apache Mesos - Getting Started](http://mesos.apache.org/gettingstarted/) to get more information.

## Requirement
- terraform

## Setup
1. Run `terraform apply` to setup up one mesos master node and two mesos agent nodes.
1. Run `$HOME/mesos-1.1.0/build/bin/mesos-master.sh --ip=<IP of mesos master> --work_dir=/var/lib/mesos` on mesos master node to start mesos master.
1. Run `$HOME/mesos-1.1.0/build/bin/mesos-agent.sh --master=<IP of mesos master>:5050 --work_dir=/var/lib/mesos` on mesos agent nodes to start mesos agent.
1. Visit `http://<IP of mesos master>:5050` and see the mesos web page.

## Run sample framework
- Run `$HOME/mesos-1.1.0/build/src/test-framework --master=<IP of mesos master>:5050` to run C++ framework.
- Run `$HOME/mesos-1.1.0/build/src/examples/java/test-framework <IP of mesos master>:5050` to run java framework.
- Run `$HOME/mesos-1.1.0/build/src/examples/python/test-framework <IP of mesos master>:5050` to run python framework.

## Author
[shibataka000](https://github.com/shibataka000)
