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

### Getting Started with Ansible

Ansible is a configuration management (CM) tool that can orchestrate the
provisioning of infrastructure. Ansible uses a _declarative configuration
style_, which means it allows you to describe what the desired state of
infrastructure should look like. This is in contrast to an _imperative
configuration style_, which requires you to supply all the details on the
desired state of infrastructure.

Ansible uses Yet Another Markup Language (YAML), which is a data serialisation
language used by Ansible to describe complex data structures and tasks. Ansible
applies its configuration changes over SSH.

Ansible is an agentless automation tool that you install on a single host
(referred to as the control node). For your control node, you can use nearly
any UNIX-like machine with Python 3.9 or newer installed. The managed node (the
machine that Ansible is managing) does not require Ansible to be installed, but
requires Python 2.7, or Python 3.5 - 3.11 to run Ansible library code. The
managed node also needs a user account that can SSH to the node with an
interactive POSIX shell.

[Install](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
using `pip`. The `--user` flag will install packages in the home directory.
This is not necessary if you are using Conda or installing into a virtual
environment.

```console
# install
python3 -m pip install --user ansible

# upgrade
python3 -m pip install --upgrade --user ansible

# verify
ansible --version
```

#### Key Ansible Concepts

* Playbook - A collection of ordered tasks or roles that you can use to
  configure hosts. A playbook is like an instruction manual on how to assemble
  a host. Inside the YAML file are different sections. The first section
  functions as the header, which is a good place to set global variables to use
  throughout the playbook. For example, setting the name of the play, the
  hosts, the remote_user, and the privileged escalation method.
* Control node - Any machine that has Ansible installed and is used to run
  playbooks or commands.
* Inventory - A file containing a list of hosts or groups of hosts that Ansible
  can communicate with.
* Module - A module encapsulates the details of how to perform certain actions
  across operating systems, such as how to install a software package. Ansible
  comes preloaded with many modules.
* Task - A command or action (such as installing software or adding a user)
  that is executed on the managed host.
* Role - A group of tasks and variables that is organised in a standardised
  directory structure and defines a particular purpose for the server and can
  be shared with other users for a common goal. A typical role could configure
  a host to be a database server. This role would include all the files and
  instructions necessary to install the database application, configure user
  permissions, and apply seed data.

The `ansible` command is primarily used for running _ad hoc_ or one-time
commands that you execute from the command line like instructing a group of web
servers to restart Nginx.

```console
ansible webservers -m service -a "name=nginx state=restarted" --become
```

The command above instructs Ansible to restart Nginx on a group of hosts called
_webservers_. The mapping for the _webservers_ group would be located in the
inventory file. The Ansible service module interacts with the OS to perform the
restart. Extra arguments to the service module are passed with the `-a`
parameter, which provided the name of the service (`nginx`) and that it should
be restarted. The `--become` flag asks for privilege escalation.

The `ansible-playbook` command runs playbooks. The following instructs
`ansible-playbook` to execute the `aws-cloudwatch.yml` playbook against a group
of hosts called `dockerhosts`.

```console
ansible-playbook -l dockerhosts aws-cloudwatch.yml
```

The `dockerhosts` need to be listed in the inventory file for the command to
succeed. If you do not provide a subset of hosts with the `-l` parameter,
Ansible will assume you want to run the playbook on all the hosts found in your
inventory file.

## Containerisation

A container is the running instance of a container image. Containers provide a
means to run code in a predictable and isolated manner. The current _de facto_
standard in containerisation is Docker. The Docker framework consists of a
Docker daemon (server), a `docker` command line clients, and other tools.
Docker uses Linux kernel features to build and run containers and partitions
the operating system into what appears to be separate isolated servers.

A `Dockerfile` describes how to build a container image that is made up of
different layers. Container images can be distributed and served from a service
called a registry, such as [Docker Hub](https://hub.docker.com/).

Docker can stack different layers on top of each other because it uses the
_union filesystem_ (UFS), which allows multiple filesystems to come together
and create what looks like a single filesystem.

### Namespaces and Cgroups

Docker containers are separated from the host by using boundaries and limited
views called _namespaces_ and _cgroups_. These are kernel features that limit
what a container can see and use. Namespaces restrict global system resources
for a container and without namespaces, a container could have free run of the
system.

Common kernel namespaces include the following:

* Process ID (PID) - Isolates the process IDs.
* Network (net) - Isolates the network interface stack.
* UTS - Isolates the hostname and domain name.
* Mount (mnt) - Isolates the mount points.
* IPC - Isolates the SysV-style interprocess communication.
* User - Isolates the user and group IDs.

Cgroups manage and measure the resources a container can use. They set
resources limitations and prioritisation for processes. The most common
resources Docker sets with cgroups are:

* Memory
* CPU
* Disk I/O
* Network

Cgroups make it possible to stop a container from using up all the resources of
the host.

Namespaces limit what can be seen and cgroups limit what can be used.

### Container orchestration

Kubernetes or K8s is an open-source orchestration system used to manage
containers. Kubernetes comes preloaded with some useful patterns (such as
networking, role-based access control, and versioned APIs), but it is meant to
be a foundational framework for building infrastructure and tools.

Kubernetes (which means _helmsman_ [a person who steers a ship or boat] in
Greek) evolved from Borg and Omega both developed at Google. It was
open-sourced in 2014 and has great community support.

A Kubernetes cluster consists of one or more control plane nodes and one or
more worker nodes. A _node_ can be a cloud VM or a Raspberry Pi server. The
_control plane nodes_ handle things like the Kubernetes API calls, the cluster
state, and the scheduling of containers. The core services (such as the API,
etcd, and the scheduler) run on the control plane. The _worker nodes_ run the
containers and resources that are scheduled by the control plane.

_Node affinity_ is when an application has preference for a specific worker
node (that has been tuned/setup for a specific use case).

### Kubernetes Workload Resources

A _resource_ is a type of object that encapsulates state and intent. If a
workload running on Kubernetes were a car, the resources would describe the
parts of the car; you could set your car up with two seats and four doors. You
would not have to understand how to make a seat or door; Kubernetes will
maintain the given count for both. Kubernetes resources are defined in a file
called a _manifest_.

Below are commonly used Kubernetes resources in a modern application stack.

* Pods - _Pods_ are the smallest building blocks in Kubernetes and they form
  the foundation for working with containers. A Pod is made up of one or more
  containers that share network and storage resources. Each container can
  connect to the other containers and all containers can share a directory
  between them by a mounted volume. However, you won't deploy Pods directly but
  instead they will be incorporated into a higher-level abstraction layer like
  a ReplicaSet.
* ReplicaSet - A ReplicaSet resource is used to maintain a fixed number of
  identical Pods. If a Pod is killed or deleted, the ReplicaSet will create
  another Pod to take its place. You'll only want to use a ReplicaSet if you
  need to create a custom orchestration behaviour. Typically, you will use a
  Deployment to manage your application instead.
* Deployments - A Deployment is a resource that manages Pods and ReplicaSets.
  **It is the most widely used resource for governing applications**. A
  Deployment's main job is to maintain the state that is configured in its
  manifest. For example, you can define the number of Pods along with the
  strategy for deploying new Pods. The Deployment resource controls a Pod's
  lifecycle, from creation, to updates, to scaling, to deletion. You can also
  roll back to earlier versions of a Deployment if necessary. Anytime your
  application needs to be long lived and fault tolerant, a Deployment should be
  your first choice.
* StatefulSets - A StatefulSet is a resource for managing stateful
  applications, such as PostgreSQL, ElasticSearch, and etcd. Similar to a
  Deployment, it can manage the state of Pods defined in a manifest. However,
  it also adds features like managing unique Pod names, managing Pod creation,
  and ordering termination. Each Pod in a StatefulSet has its own state and
  data bound to it. If you are adding a stateful application to your cluster,
  choose a StatefulSet over a Deployment.
* Services - Services allow you to expose applications running in a Pod or
  group of Pods within the Kubernetes cluster or over the internet. You can
  choose from the following basic Service types:
    * ClusterIP - This is the default type when you create a Service. It is
    assigned an internal routable IP address that proxies connections to one or
    more Pods. You can access a ClusterIP only from within the Kubernetes
    cluster.
    * Headless - This does not create a single-service IP address. It is not
    load balanced.
    * NodePort - This exposes the Service on the node's IP addresses and port.
    * LoadBalancer - This exposes the Service externally. It does this either
    by using a cloud provide's component, like AWS's Elastic Load Balancing
    (ELB), or a bare-metal solution, like MetalLB.
    * ExternalName - This maps a Service to the contents of the externalName
    field to a CNAME record with its value.
* Volumes - A Volume is basically a directory or a file that all containers in
  a Pod can access but with some caveats. If an entire Pod is killed, the
  Volume and its contents will also be removed. Use a Persistent Volume (PV)
  for storage that is not linked to a Pod's lifecycle.
* Secrets - Secrets are convenient resources for safely and reliably sharing
  sensitive information with Pods. Secrets can be accessed either via
  environment variables or as a Volume mount inside a Pod.
* ConfigMaps - ConfigMaps are used to mount nonsensitive configuration files
  inside a container. A Pod's containers can access the ConfigMap from an
  environment variable, from command line arguments, or as a file in a Volume
  mount.
* Namespaces - The Namespace resource is used to divide a Kubernetes cluster
  into several smaller virtual clusters. When a Namespace is set, it provides a
  logical separation of resources, even though those resources can reside on
  the same nodes.
