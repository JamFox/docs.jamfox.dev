---
title: "Hashicorp Consul"
---

!!! info
    [Consul Homepage](https://www.consul.io/) |
    [Consul Docs](https://developer.hashicorp.com/consul/docs) |
    [Consul Connect Docs](https://developer.hashicorp.com/consul/docs/connect) |
    [Envoy Proxy Homepage](https://www.envoyproxy.io/) |
    [Envoy Proxy Docs](https://www.envoyproxy.io/docs) |
    [Cloud Native Landscape](https://landscape.cncf.io/)

Consul is a service networking solution that enables teams to manage secure network connectivity between services and across multi-cloud environments and runtimes. Consul offers service discovery, identity-based authorization, L7 traffic management, and service-to-service encryption.

Consul's main power lies in:

- finding microservices easily to, for example, provide load balancing to multiple replicas of a containerized service.
- providing loosely coupled encrypted communication between (micro)services.

## Concepts

### Service discovery

[Consul](https://developer.hashicorp.com/consul/docs) is used as a centralized registry that discovers, tracks, and monitors services. Consul can be the single source of truth for cataloging and maintaining a record of all services.

Traditionally, applications and services tend to be static where IP's remain unchanged. However, this becomes a challenge with containerized/scalable applications that are much more dynamic. This is even more evident today with microservices that are ephemeral and constantly changing.

Service discovery uses a service's identity instead of traditional access information (IP address and port). This allows dynamically mapping services and tracking any changes within a service catalog. Service consumers (users or other services) then use DNS to dynamically retrieve other service's access information from the service catalog.

Discovery works by leveraging health checks. The check can be as simple as a HTTP call to the service, ping request, or something more sophisticated like launching an external program and analyzing its exit code. Then, depending on check result, Consul will put the service (or all services at the host) to one of the three states: healthy, warning or critical. `healthy` and `warning` services will behave like usual, but Consul gives special treatment for `critical` ones: they won't be discoverable via Consul DNS. What's even more, if service doesn't get back healthy in given amount of time, it can be unregistered completely. However, such behavior is disabled by default.

### Service mesh

[Consul Connect](https://developer.hashicorp.com/consul/docs/connect) enables simplified network topologies and management while also strengthening security and maintaining high performance in a distributed system.

It works by adding [Envoy Proxy](https://www.envoyproxy.io/) sidecars to services. The sidecar service aims to add or augment an existing main service's functionality without changing the main service itself. The sidecar service starts and runs simultaneously with a main service.

The advantage to the sidecar architecture is that the services being deployed do not need to be aware of the service mesh or the locations of the services that it needs to communicate with, instead all communication (including encrypting it and finding the services) is done by the sidecars, the services themselves are being told to look for communications on localhost. With a highly replicated/distributed/loosely coupled microservice architecture it is not feasible to keep updating ports and IPs of services so that they can communicate to each other because usually this architecture is built to be ephemeral (meaning the microservices can go down, do rolling updates, scale up or down), so the number of services and their IPs can and will change, sometimes even minute to minute. So instead, using Consul Connect allows telling any service to listen on localhost by connecting the sidecar to figure out and make everything that is needed for communication between services available to that service's localhost.

## Usage

### Consul DNS for service discovery

After getting Consul up and running, it is possible to use port 8600 of Consul server nodes to query Consul's service catalog for healthy instances of those services. However this requires pointing services to the Consul instances on port 8600 or running Consul with an administrative or root account to serve it from port 53. A better, more dynamic way of resolving the Consul service catalog is to use [DNS forwarding](https://developer.hashicorp.com/consul/tutorials/networking/dns-forwarding). This way the lab's internal DNS server passes requests from port 53 to Consul's DNS on 8600 as needed. This means not having to worry about clients that cannot deal with DNS being on a non-standard port, whilst also allowing them to lookup services from Consul.

My choice of DNS is Dnsmasq and I am using a Debian based OS that uses systemd so there is a caveat of trying to [figure out how to avoid a DNS lookup loop](https://github.com/hashicorp/consul/issues/4155). The options are:

- disable `systemd-resolved` service
- use `systemd-resolved` instead of Dnsmasq
- point `systemd-resolved` to point to Dnsmasq

After deciding on the appropriate setup it is a simple matter of adding another config file to `/etc/dnsmasq.d/` with the following contents:

```
# Enable reverse DNS lookups for your netblock
rev-server=192.168.0.0/24,127.0.0.1#8600

# Enable forward lookup of the 'consul' domain to your consul server instances
server=/consul/192.168.0.120#8600
server=/consul/192.168.0.121#8600
server=/consul/192.168.0.122#8600
```

Some other optional settings that can be useful to add:

```
# Accept DNS queries only from hosts whose address is on a local subnet.
local-service

# Don't poll /etc/resolv.conf for changes
no-poll

# Don't read /etc/resolv.conf
no-resolv

# Specify other DNS servers for queries not handled by consul
server=8.8.8.8

# Increase the size of dnsmasq's cache
cache-size=65536
```

Then restart Dnsmasq with `systemctl restart dnsmasq` et voila!

Check to see if the names resolve by using `dig consul.service.consul` to query the addresses of active Consul server nodes or `<YOUR SERVICE>.service.consul` for active instances of whatever service you have in your Consul catalog:

```
;; QUESTION SECTION:
;consul.service.consul.         IN      A

;; ANSWER SECTION:
consul.service.consul.  0       IN      A       192.168.0.122
consul.service.consul.  0       IN      A       192.168.0.120
consul.service.consul.  0       IN      A       192.168.0.121
```

For testing purposes, you can shut down one of your instances of whatever you're querying and doing `dig` on it again to see that there should be one less answer:

```
;; QUESTION SECTION:
;consul.service.consul.         IN      A

;; ANSWER SECTION:
consul.service.consul.  0       IN      A       192.168.0.122
consul.service.consul.  0       IN      A       192.168.0.120
```
