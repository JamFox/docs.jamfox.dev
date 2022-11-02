---
title: "Dnsmasq"
---

!!! info
    [How DNS Works](https://howdns.works/) |
    [Dnsmasq Homepage](https://dnsmasq.org/)

Dnsmasq provides network infrastructure for small networks: DNS, DHCP, router advertisement and network boot. It is designed to be lightweight and have a small footprint, suitable for resource constrained routers and firewalls.

It's simple configuration and lightweight nature makes it a perfect fit for a homelab DNS from a low-powered device like a Raspberry.

## Usage

### Configuration files

Dnsmasq reads all `.conf` files under `/etc/dnsmasq.d/`.

Some useful options for Dnsmasq configuration files:

```
# Don't poll /etc/resolv.conf for changes
no-poll
# Don't read /etc/resolv.conf
no-resolv
# Only accept queries from local IPs
local-service
# Never forward queries for plain names, without dots or domain parts, to upstream nameservers
domain-needed
# Bogus private reverse lookups. All reverse lookups for private IP ranges (ie 192.168.x.x, etc) which are not found in /etc/hosts or the DHCP leases file are answered with "no such domain" rather than being forwarded upstream
bogus-priv

# Specify other DNS servers for queries not handled by internal DNSs
server=8.8.8.8
server=4.4.4.4

# Queries in these domains are answered from /etc/hosts or DHCP only.
#local=/jamfox.dev/

# Allows DHCP hosts to have FQDN, provides the domain part for "expand-hosts"
#domain=/jamfox.dev/

# Increase the size of dnsmasq's cache
cache-size=65536

# DNS records
address=/pve0.jamfox.dev/192.168.0.100

# Enable reverse DNS lookups for a netblock
rev-server=192.168.0.0/24,127.0.0.1#8600

# Enable forward lookup of the 'consul' domain to consul server instances
server=/consul/192.168.0.120#8600
```
