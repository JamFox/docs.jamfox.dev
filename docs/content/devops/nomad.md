---
title: "Hashicorp Nomad"
---

!!! info
    [Nomad Homepage](https://www.nomadproject.io/) |
    [Nomad Docs](https://developer.hashicorp.com/nomad/docs) |
    [Cloud Native Landscape](https://landscape.cncf.io/)

Nomad is a flexible workload orchestrator that enables an organization to easily deploy and manage any containerized or legacy application using a single, unified workflow. Nomad can run a diverse workload of Docker, non-containerized, microservice, and batch applications.

Nomad enables developers to use declarative infrastructure-as-code for deploying applications. Nomad uses bin packing to efficiently schedule jobs and optimize for resource utilization.

Nomad is comparable to Kubernetes in that it can:

- deploy containers and legacy applications.
- simplify container deployment and management (health checking, timeouts, retries, zero downtime updates etc).
- scale easily by abstracting complexity of orchestrating microservices in multiple namespaces in multiple data centres in multiple regions.

[Differences between Nomad and Kubernetes](https://developer.hashicorp.com/nomad/docs/nomad-vs-kubernetes) are that Kubernetes tries to be more of a complete package, while [Nomad does not provide](https://www.hashicorp.com/blog/a-kubernetes-user-s-guide-to-hashicorp-nomad):

- Secrets management [(although *technically* Kubernetes does not have secrets management built in)](https://www.macchaffee.com/blog/2022/k8s-secrets/)
- Service discovery and service mesh
- Load balancing
- Configuration management
- Custom controllers

Instead Nomad takes the approach of separating each aspect to a separate product that can be used together or alone depending on the use case. Kubernetes comes with batteries built in, while with Nomad you decide if you even need the batteries or if you want to build the batteries yourself.
