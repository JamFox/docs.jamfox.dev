---
title: "DNS"
---

The Domain Name System (DNS) is the phonebook of the internet. Humans access information online through domain names, like nytimes.com or espn.com because this is easier to remember a bunch of "random" numbers (IP addresses). But web browsers interact through IP addresses. So we have a middle man called DNS that translates domain names to IP addresses so browsers can load internet resources.

Each device connected to the internet has a unique IP address which other machines use to find the device. DNS servers eliminate the need for humans to memorize IP addresses such as 192.168.1.1 (in IPv4), or more complex newer alphanumeric IP addresses such as 2400:cb00:2048:1::c629:d7a2 (in IPv6).

Anyone that wants people to find and remember their website on the internet will need to set up DNS record(s).

!!! info
    [How DNS Works](https://howdns.works/)

## Glossary

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
