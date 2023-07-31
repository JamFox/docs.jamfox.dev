---
title: "Kubernetes"
---

!!! info
    [Kubernetes Docs](https://kubernetes.io/docs/home/) |
    [Cloud Native Landscape](https://landscape.cncf.io/) |
    [Kubernetes Secrets threat model](https://www.macchaffee.com/blog/2022/k8s-secrets/) |
    [Managing Kubernetes without losing your cool](https://marcusnoble.co.uk/2022-07-04-managing-kubernetes-without-losing-your-cool/)

I often see a lot of skepticism and even hate towards Kubernetes. However the main problem with Kubernetes is not itself, but the hype around it. It's simply used and adopted in places without sufficient research/knowledge about what it does, what problems it solves and how to leverage and maintain it:

![The main problem with Kubernetes is not itself, but the hype around it](https://pbs.twimg.com/media/EDrZEKCWwAAG_Ty.jpg)

Since Kubernetes is/wants to be the end all be all of container orchestration and do EVERYTHING it can within reason, then that means anyone trying to get into it must more or less be familiar with every aspect of it.

[Simple overview of monolith apps, containerization and K8s](https://cloud.google.com/kubernetes-engine/kubernetes-comic)

Kubernetes does:

- service discovery and load balancing
- storage orchestration
- automated rollouts and rollbacks
- automatic bin packing
- self-healing
- secret and configuration management

Kubernetes does not:

- deploy source code and does not build application (any cicd, gitops, ops flows must be figured out)
- provide application-level services (databases etc)
- dictate logging, monitoring, or alerting solutions (it has logging and monitoring, but at a very basic level)
- provide nor mandate a configuration language/system, it's declarative API may be targeted by arbitrary forms of declarative specifications (many different tools that can be used to declare kube resources with the kube API exist)

HOWEVER all of the things that "Kubernetes does not" do can run ON Kubernetes, and/or can be accessed by applications running on Kubernetes through some mechanisms.

## Usage

This doc will probably not have very detailed examples because Kubernetes is in VERY active development so incompatible changes and non-working, broken examples and not-so-thorough documentation is surely to follow. Related to the last point: any documentation should have versions **everywhere**.
