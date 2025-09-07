---
title: "firewalld"
---

!!! info
    [Understanding Firewalld in Multi-Zone Configurations](https://www.linuxjournal.com/content/understanding-firewalld-multi-zone-configurations)

## Precedence

Active zones fulfill two different roles. Zones with associated interface(s) act as interface zones, and zones with associated source(s) act as source zones (a zone could fulfill both roles). Firewalld handles a packet in the following order:

1. The corresponding source zone. Zero or one such zones may exist. If the source zone deals with the packet because the packet satisfies a rich rule, the service is whitelisted, or the target is not default, we end here. Otherwise, we pass the packet on.
2. The corresponding interface zone. Exactly one such zone will always exist. If the interface zone deals with the packet, we end here. Otherwise, we pass the packet on.
3. The firewalld default action. Accept icmp packets and reject everything else.

The take-away message is that **source zones have precedence over interface zones**. Therefore, the general design pattern for multi-zoned firewalld configurations is to create a privileged source zone to allow specific IP's elevated access to system services and a restrictive interface zone to limit the access of everyone else.

## Gateway

Example firewalld config for gateway host:

```yml
firewalld_zones:
  # Internal zone
  - name: "internal"
    short: "Internal"
    description: "Internal networks to route through the gateway."
    # -A FORWARD -i eth0 -j ACCEPT
    forward: true
    # -A INPUT -i eth0 -j ACCEPT
    target: "ACCEPT"
    source:
      - address: "10.10.0.0/16"
    interface:
      - name: "eth0"
  # External zone
  - name: "external"
    short: "External"
    description: "WAN to route to from gateway."
    # -A POSTROUTING -o eth1 -j MASQUERADE
    masquerade: true
    # -A FORWARD -i eth1 -o eth0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    forward: true
    interface:
      - name: "eth1"
    source:
      - address: "193.40.251.4/32"
      - address: "193.40.244.192/27"
      - address: "10.10.2.1/32"
firewalld_config:
  DefaultZone: "external"
firewalld_policies:
  - name: "internal-external"
    short: "Internal to External"
    description: "Internal to External policy for gateway routing"
    ingress-zone:
      - name: "internal"
    egress-zone:
      - name: "external"
    target: "ACCEPT"
```