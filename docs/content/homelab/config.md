---
title: "Configuration Management (Ansible)"
---

Ansible was the obvious choice for me as I had quite a lot of experience with it. For configuration management it made sense to go with something simple to ease bootstrapping and favoring mutability for fastest development. Running a whole platform like Puppet did not make sense because of bootstrapping and resource overhead. Ansible is simple to write, understand and manage if written well from the get-go.

Also knowing Ansible I knew how slow it can be. There's two ways of solving this: using push mode with a central management (with homebrew or AWX/Ansible Tower) with parallel playbook execution for each host OR pull mode where each host essentially configures itself. It is quite evident that pull mode is the more scalable and resource efficient so I went with that.

So I settled on the following requirements:

- Easy to bootstrap (i.e. couple of commands excluding secrets)
- Scalable (execution time does not depend on the number of hosts)
- Simple to modify and manage (DRY monorepo for all hosts)

The solution was [jamlab-ansible](https://github.com/JamFox/jamlab-ansible): Homelab bootstrap and pull-mode configuration management with Ansible and bash. Most of it is "inspired" by a similar system that we used at CERN.
