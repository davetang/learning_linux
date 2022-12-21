## DevOps

Notes from [DevOps for the Desperate](https://nostarch.com/devops-desperate), a
book that teaches you the concepts, commands, and techniques that will provide
a solid foundation in DevOps, reliability, and modern application stacks.
Repository for this book is available on
[GitHub](https://github.com/bradleyd/devops_for_the_desperate).

Writing configuration files, enforcing observability, and setting up continuous
integration/continuous delivery (CI/CD) pipelines have become the norm in
software development. There is a heavy focus on microservices, container
orchestration (Kubernetes), automated code delivery (CI/CD), and observability
(detailed logging, tracing, monitoring, and alerting). In addition, DevSecOps
(security) is becoming an essential part of the build process rather than a
post-release afterthought.

## Setting up Virtual Machines

Provisioning, i.e. setting up, a Virtual Machine (VM) is the act of configuring
a VM for a specific purpose. There are various tools for creating and
configuring a VM. [Vagrant](https://en.wikipedia.org/wiki/Vagrant_(software))
automates the process of creating VMs and
[Ansible](https://en.wikipedia.org/wiki/Ansible_(software)) configures the VM
once it is running.

[Infrastructure as code](https://en.wikipedia.org/wiki/Infrastructure_as_code)
(IaC) is using code to build and provision infrastructure, which allows you to
consistently, quickly, and efficiently manage and deploy applications. The
advantages include allowing the infrastructure and services to scale, reducing
operating costs, decreasing recovery time, and minimising the chance of
configuration errors. Treating infrastructure as code is the process of using
code to describe and manage infrastructure like VMs, network switches, and
cloud resources. Configuration management (CM) is the process of configuring
those resources for a specific purpose in a predictable, repeatable manner.
Vagrant and Ansible are considered IaC and CM, respectively.

### Vagrant

Vagrant uses a single configuration file written in Ruby and called a
_Vagrantfile_ to describe the virtual environment in code. Vagrant supports
many OS base images called _boxes_ and a list of supported boxes can be on the
[Vagrant website](https://app.vagrantup.com/boxes/search). The following sets
which box to use.

    config.vm.box = "ubuntu/focal64"

`vm.network` configures the VM's network options. The following sets the VM to
obtain its IP address from a private network using the Dynamic Host
Configuration Protocol (DHCP).

    config.vm.network "private_network", type: "dhcp"

A [provider](https://developer.hashicorp.com/vagrant/docs/providers) is a
  plug-in that knows how to create and manage a VM. Vagrant supports multiple
  providers to manage different types of machines. Each provider has common
  options such as CPU, disk, etc.

```
config.vm.provider "virtualbox" do |vb|
  vb.memory = "1024"
  vb.name = "dftd"
  --snip--
end
```

The four most used Vagrant commands are:

1. `vagrant up` - creates a VM using the Vagrantfile as a guide
2. `vagrant destroy` - destroys the running VM
3. `vagrant status` - checks the running status of a VM
4. `vagrant ssh` - accesses the VM over Secure Shell

Use `--help` to find out more information about each (sub)command.

## Useful links

* [Configure EC2 using
Vagrant](https://blog.knoldus.com/how-to-configure-aws-ec2-instance-using-vagrant/)
