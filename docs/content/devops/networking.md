---
title: "Networking"
---

## Firewalld

!!! info
    [Understanding Firewalld in Multi-Zone Configurations](https://www.linuxjournal.com/content/understanding-firewalld-multi-zone-configurations)

Note that on (RedHat/CentOS/Rocky/Alma/etc) hosts that only use NetworkManager, **to apply an interface to a zone, it must also be done with `nmcli`, applying settings only via `firewall-cmd` will not work**! Example: add via firewalld and then run `nmcli con mod eth0 connection.zone internal`

### Precedence

Active zones fulfill two different roles. Zones with associated interface(s) act as interface zones, and zones with associated source(s) act as source zones (a zone could fulfill both roles). Firewalld handles a packet in the following order:

1. The corresponding source zone. Zero or one such zones may exist. If the source zone deals with the packet because the packet satisfies a rich rule, the service is whitelisted, or the target is not default, we end here. Otherwise, we pass the packet on.
2. The corresponding interface zone. Exactly one such zone will always exist. If the interface zone deals with the packet, we end here. Otherwise, we pass the packet on.
3. The firewalld default action. Accept icmp packets and reject everything else.

The take-away message is that **source zones have precedence over interface zones**. Therefore, the general design pattern for multi-zoned firewalld configurations is to create a privileged source zone to allow specific IP's elevated access to system services and a restrictive interface zone to limit the access of everyone else.

### Gateway example

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

### Wireguard VPN example

Example VPN example with Wireguard set up with wg0 iface:

```yml
firewalld_enabled: true
firewalld_service_state: started
firewalld_remove_unmanaged: false
firewalld_zones:
  - name: "public"
    short: "Public"
    description: "For use in untrusted public networks. You do not trust the other computers. Only selected incoming connections are accepted."
    interface:
      - name: "enp3s0" # Also needs to be added with network role (check host_vars) or nmcli
    service:
      - name: "ssh"
    port:
      - { port: "51821", protocol: "udp" } # VPN port
    rule:
      - source: # Needed to route to other hosts in VPN network
          address: "10.7.0.0/24"
        destination: "not address=10.7.0.0/24"
        masquerade: true
  - name: "internal"
    short: "Internal"
    description: "For use on internal networks. You mostly trust the other computers. Only selected incoming connections are accepted."
    interface:
      - name: "wg0" # Also needs to be added via nmcli: nmcli con mod wg0 connection.zone internal
    masquerade: true
    service:
      - name: "ssh"
  - name: "trusted"
    short: "Trusted"
    description: "All network connections in trusted sources are accepted."
    target: "ACCEPT"
    source:
      - address: "10.7.0.0/24"
```

## Netplan

Netplan will ignore ifaces that are not defined in the configuration, but will overwrite settings on ifaces which are defined in the configuration file.

Note that **changing bond parameters in netplan might need a [reboot](https://bugs.launchpad.net/ubuntu/+source/nplan/+bug/1746419)**! It is possible to use a workaround similar to `ip link del dev bond0 && netplan apply` but **this still briefly disconnects the machine from the networks used by that bond**!

### Symmetric routing for VIP

!!! info
    [How to use netplan to create two separate routing tables?](https://askubuntu.com/questions/1169002/how-to-use-netplan-to-create-two-separate-routing-tables)

In highly available setups, traffic sourced from certain IPs (e.g., floating VIPs from keepalived etc) may need to leave through a specific interface or gateway, separate from the default uplink. This ensures symmetric routing, correct NAT behavior, and avoids disrupting other nodes in the cluster.

```yml
network:
  version: 2
  ethernets:
    eno1:
      addresses: [172.21.24.113/24] # Internal IP
      nameservers:
        addresses: [172.21.24.10]
      routes:
        - to: default
          via: 172.21.24.10 # Default route to central management node with internet route
          metric: 100
  bridges:
    br-pubapi:
      interfaces: [vlan2125]
      addresses: [172.21.25.11/24]
      routes:
        - to: default
          via: 172.21.25.254
          table: 2
        - to: 172.20.12.0/23
          via: 172.21.25.254
      routing-policy:
        - from: 172.21.25.10
          table: 2
```

`table: 2` defines a dedicated routing table for traffic sourced from the VIP (`172.21.25.10`). Routes in this table ensure traffic leaves via the correct gateway (`br-pubapi -> 172.21.25.254`). Backup nodes without the VIP will ignore this rule, leaving default routes intact.

Equivalent `ip` commands (These commands only apply to the current runtime session; they are lost after reboot unless also added to your network config to be applied after reboot or to keepalived config for example):

```bash
ip route add default via 172.21.25.254 dev br-pubapi table 2
ip rule add from 172.21.25.10 table 2 priority 32765
```

Verify:

```bash
ip rule show
ip route show
ip rule show table 2
ip route show table 2
```

## DNS 

The Domain Name System (DNS) is the phonebook of the internet. Humans access information online through domain names, like nytimes.com or espn.com because this is easier to remember a bunch of "random" numbers (IP addresses). But web browsers interact through IP addresses. So we have a middle man called DNS that translates domain names to IP addresses so browsers can load internet resources.

Each device connected to the internet has a unique IP address which other machines use to find the device. DNS servers eliminate the need for humans to memorize IP addresses such as 192.168.1.1 (in IPv4), or more complex newer alphanumeric IP addresses such as 2400:cb00:2048:1::c629:d7a2 (in IPv6).

Anyone that wants people to find and remember their website on the internet will need to set up DNS record(s).

!!! info
    [How DNS Works](https://howdns.works/)

### Glossary

**A Record** (aka Address Mapping Record, DNS host record) - The 'A' in A Record stands for 'address.' This is the most popular DNS record type. Its function? Connecting a website domain or subdomain names, such as  example.com or blog.example.com, to a numerical IPV4 address such as 127.0.0.1. Think of this as the home address of a website.

**AAAA Record** - This behaves the same as the 'A' record but points the domain to an IPv6 address. The difference between IPv4 and IPv6 is the length of the IP address name from 32 bit to 128 bit consecutively. Because many domains use domain registrars, their nameservers have an IPv4 address, so an AAAA record is not present.

**CNAME Record** - CNAME stands for "canonical name" and will always point one name used by a website to an A record.

**MX Record** - A DNS 'mail exchange' (MX) record directs email to a mail server. The MX record indicates how email messages should be routed in accordance with the Simple Mail Transfer Protocol (SMTP, the standard protocol for all email). Like CNAME records, an MX record must always point to another domain.

**SRV record** - A service record (SRV) is a specification of data in the Domain Name System defining the location (i.e., the port number) of servers for specified services (e.g., Minecraft). Think of this as 'plugging in' a service to a port.
**TXT Record** - Provides the ability to associate other services, or sometimes a mail service, to a domain. This is to help humans using words recognize which server (or software) is using their system. It's possible to add many TXT records to describe other numerical ideas.

**CERT Record** - The 'certificate record' stores any public-key certificates. CERT records give the party in control of the authoritative DNS server for a specified zone permission to accept the use of a public key for authenticating communication with the server.

**PTR record** - This 'pointer' record converts an IP address into a domain name. It's known as a reverse DNS entry check to verify if a server matches the domain it claims to be from. It's an extra check used as a security measure.

**SOA record** - This record stores important information about the DNS zone for a domain, including the person responsible for the entire zone. Each zone must have an SOA record, but it's unlikely you'll have to create an SOA record directly—unless the responsible person is you. An interesting thing about SOA records is they are always distributed with a zero TTL to prohibit caching. This record cannot be adjusted or interfered with but is limited to traveling only to one server at a time.

**CAA record** - As a domain name holder, this helps you specify which Certification Authorities (CAs) can issue certificates for your domain, avoiding that error message 'this site does not have a valid certificate.'

**ALIAS record** - ALIAS is a hosting record which points one domain to another domain. Usually, a CNAME record takes priority over any other resource record for a given hostname and conflicts with such records as MX or TXT, and thus some services may be affected and will not work. Thus ALIAS (also known as a virtual host record) was introduced. It can coexist with other records which are created for the same hostname (like example.com).
