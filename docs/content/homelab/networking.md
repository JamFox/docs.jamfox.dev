---
title: "Switching and VLANs"
---

Network composes of two switches connected to the main router.

Router is connected to the AtticSwitch which is connected to the LabSwitch.

Switches are managed using [Easy Smart Configuration Utility](https://www.tp-link.com/us/support/download/tl-sg108e/).

## AtticSwitch TL-SG108PE 2.0 info

| VLAN | VLAN Name | Member Ports | Tagged Ports | Untagged Ports |
|------|-----------|--------------|--------------|----------------|
| 1    | Default   | 1-8          |              | 1-8            |

| Port | Connection |
|------|------------|
| 1PoE | Karl1      |
| 2PoE | Karl2      |
| 3PoE | -          |
| 4PoE | Printer    |
| 5    | -          |
| 6    | LabRouter  |
| 7    | -          |
| 8    | Router     |

## LabRouter Archer C7 v5.0 info

| Port | Connection  |
|------|-------------|
| WAN  | AtticSwitch |
| 1    | Karl2       |
| 2    | -           |
| 3    | -           |
| 4    | LabSwitch   |

## LabSwitch TL-SG108E 5.0 info

| VLAN | VLAN Name | Member Ports | Tagged Ports | Untagged Ports |
|------|-----------|--------------|--------------|----------------|
| 1    | Default   | 1-8          |              | 1-8            |

| Port | PVID      | LAG | Connection |
|------|-----------|-----|------------|
| 1PoE | 1         | -   | -          |
| 2PoE | 1         | -   | -          |
| 3PoE | 1         | -   | -          |
| 4PoE | 1         | -   | -          |
| 5    | 1         | -   | Sol ILO    |
| 6    | 1         | -   | Sol eno1   |
| 7    | 1         | -   | -          |
| 8    | 1         | -   | LabRouter  |
