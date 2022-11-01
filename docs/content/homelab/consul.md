---
title: "Hashicorp Consul"
---

!!! info
    [Consul Homepage](https://www.consul.io/) |
    [Consul Docs](https://developer.hashicorp.com/consul/docs) |
    [Consul Connect Docs](https://developer.hashicorp.com/consul/docs/connect) |
    [Envoy Proxy Homepage](https://www.envoyproxy.io/)

Consul is a service networking solution that enables teams to manage secure network connectivity between services and across multi-cloud environments and runtimes. Consul offers service discovery, identity-based authorization, L7 traffic management, and service-to-service encryption.

Consul's main power lies in:

- finding microservices easily to, for example, provide load balancing to multiple replicas of a containerized service.
- providing loosely coupled encrypted communication between (micro)services.

## Service discovery

[Consul](https://developer.hashicorp.com/consul/docs) is used as a centralized registry that discovers, tracks, and monitors services. Consul can be the single source of truth for cataloging and maintaining a record of all services.

Traditionally, applications and services tend to be static where IP's remain unchanged. However, this becomes a challenge with containerized/scalable applications that are much more dynamic. This is even more evident today with microservices that are ephemeral and constantly changing.

Service discovery uses a service's identity instead of traditional access information (IP address and port). This allows dynamically mapping services and tracking any changes within a service catalog. Service consumers (users or other services) then use DNS to dynamically retrieve other service's access information from the service catalog.

Discovery works by leveraging health checks. The check can be as simple as a HTTP call to the service, ping request, or something more sophisticated like launching an external program and analyzing its exit code. Then, depending on check result, Consul will put the service (or all services at the host) to one of the three states: healthy, warning or critical. `healthy` and `warning` services will behave like usual, but Consul gives special treatment for `critical` ones: they won't be discoverable via Consul DNS. What's even more, if service doesn't get back healthy in given amount of time, it can be unregistered completely. However, such behavior is disabled by default.

## Service mesh

[Consul Connect](https://developer.hashicorp.com/consul/docs/connect) enables simplified network topologies and management while also strengthening security and maintaining high performance in a distributed system.

It works by adding [Envoy Proxy](https://www.envoyproxy.io/) sidecars to services. The sidecar service aims to add or augment an existing main service's functionality without changing the main service itself. The sidecar service starts and runs simultaneously with a main service.

The advantage to the sidecar architecture is that the services being deployed do not need to be aware of the service mesh or the locations of the services that it needs to communicate with, instead all communication (including encrypting it and finding the services) is done by the sidecars, the services themselves are being told to look for communications on localhost. With a highly replicated/distributed/loosely coupled microservice architecture it is not feasible to keep updating ports and IPs of services so that they can communicate to each other because usually this architecture is built to be ephemeral (meaning the microservices can go down, do rolling updates, scale up or down), so the number of services and their IPs can and will change, sometimes even minute to minute. So instead, using Consul Connect allows telling any service to listen on localhost by connecting the sidecar to figure out and make everything that is needed for communication between services available to that service's localhost.
