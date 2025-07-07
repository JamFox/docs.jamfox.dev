---
title: "Ceph Storage"
---

!!! info
    [Ceph architecture docs](https://docs.ceph.com/en/latest/architecture/)  |
    [Ceph Hardware recommendations](https://docs.ceph.com/en/latest/start/hardware-recommendations/) |
    [ceph-deep-dive](https://github.com/wuhongsong/ceph-deep-dive)

## Architecture

[Ceph architecture docs](https://docs.ceph.com/en/latest/architecture/).

Ceph provides an infinitely scalable Ceph Storage Cluster based upon [RADOS](https://ceph.io/en/news/blog/2009/the-rados-distributed-object-store/), a reliable, distributed storage service that uses the intelligence in each of its nodes to secure the data it stores and to provide that data to clients.

A Ceph Storage Cluster consists of multiple types of daemons:

- **Ceph Monitor**: maintain the master copy of the cluster map, which they provide to Ceph clients. The existence of multiple monitors in the Ceph cluster ensures availability if one of the monitor daemons or its host fails.
- **Ceph OSD Daemon**: checks its own state and the state of other OSDs and reports back to monitors.
- **Ceph Manager**: serves as an endpoint for monitoring, orchestration, and plug-in modules.
- **Ceph Metadata Server**: manages file metadata when CephFS is used to provide file services.

Storage cluster clients and Ceph OSD Daemons use the CRUSH algorithm to compute information about the location of data. By using the CRUSH algorithm, clients and OSDs avoid being bottlenecked by a central lookup table.

The Ceph Storage Cluster receives data from Ceph Clients--whether it comes through a Ceph Block Device, Ceph Object Storage, the Ceph File System, or a custom implementation that you create by using librados. The data received by the Ceph Storage Cluster is stored as RADOS objects. Each object is stored on an Object Storage Device (this is also called an “OSD”). Ceph OSDs control read, write, and replication operations on storage drives. The default BlueStore back end stores objects in a monolithic, database-like fashion.

OSD is usually just a disk, but it can be some configuration of virtual abstraction (SSD split into 3 partitions providing journaling for 3 HDDs, where 1 OSD is 1 SSD partition + 1 HDD for example).

Ceph OSD Daemons store data as objects in a flat namespace. This means that objects are not stored in a hierarchy of directories. An object has an identifier, binary data, and metadata consisting of name/value pairs. Ceph Clients determine the semantics of the object data. For example, CephFS uses metadata to store file attributes such as the file owner, the created date, and the last modified date.

### High-Availability

Ceph eliminates the centralized component. This enables clients to interact with Ceph OSDs directly. Ceph OSDs create object replicas on other Ceph Nodes to ensure data safety and high availability. Ceph also uses a cluster of monitors to ensure high availability. To eliminate centralization, Ceph uses an algorithm called CRUSH.

A Ceph Client must contact a Ceph Monitor and obtain a current copy of the cluster map in order to read data from or to write data to the Ceph cluster.

It is possible for a Ceph cluster to function properly with only a single monitor, but a Ceph cluster that has only a single monitor has a single point of failure: if the monitor goes down, Ceph clients will be unable to read data from or write data to the cluster.

Ceph should be able to recover from [a total disaster](https://www.youtube.com/watch?v=8paAkGx2_OA) by itself.

Ceph uses the Paxos consensus algorithm.

Direct interactions between Ceph clients and OSDs require authenticated connections. The cephx authentication system establishes and sustains these authenticated connections.

The `cephx` protocol operates in a manner similar to Kerberos.

### Cluster Map

In order for a Ceph cluster to function properly, Ceph Clients and Ceph OSDs must have current information about the cluster’s topology. Current information is stored in the “Cluster Map”, which is in fact a collection of five maps. The five maps that constitute the cluster map are:

- **The Monitor Map**: Contains the cluster `fsid`, the position, the name, the address, and the TCP port of each monitor. The monitor map specifies the current epoch, the time of the monitor map’s creation, and the time of the monitor map’s last modification. To view a monitor map, run `ceph mon dump`.
- **The OSD Map**: Contains the cluster `fsid`, the time of the OSD map’s creation, the time of the OSD map’s last modification, a list of pools, a list of replica sizes, a list of PG numbers, and a list of OSDs and their statuses (for example, `up`, `in`). To view an OSD map, run `ceph osd dump`.
- **The PG Map**: Contains the PG version, its time stamp, the last OSD map epoch, the full ratios, and the details of each placement group. This includes the PG ID, the Up Set, the Acting Set, the state of the PG (for example, `active + clean`), and data usage statistics for each pool.
- **The CRUSH Map**: Contains a list of storage devices, the failure domain hierarchy (for example, `device`, `host`, `rack`, `row`, `room`), and rules for traversing the hierarchy when storing data. To view a CRUSH map, run `ceph osd getcrushmap -o {filename}` and then decompile it by running `crushtool -d {comp-crushmap-filename} -o {decomp-crushmap-filename}`.
- **The MDS Map**: Contains the current MDS map epoch, when the map was created, and the last time it changed. It also contains the pool for storing metadata, a list of metadata servers, and which metadata servers are `up` and `in`. To view an MDS map, execute `ceph fs dump`.

Each map maintains a history of changes to its operating state. Ceph Monitors maintain a master copy of the cluster map. This master copy includes the cluster members, the state of the cluster, changes to the cluster, and information recording the overall health of the Ceph Storage Cluster.

### Pools, PGs, OSDs

Each pool has a number of placement groups (PGs) within it. CRUSH dynamically maps PGs to OSDs. When a Ceph Client stores objects, CRUSH maps each RADOS object to a PG.

PGs as a “layer of indirection” allows Ceph to rebalance dynamically when new Ceph OSD Daemons and their underlying OSD devices come online. 

Object locations must be computed. The client requires only the object ID and the name of the pool in order to compute the object location.

When you add or remove a Ceph OSD Daemon to a Ceph Storage Cluster, the cluster map gets updated with the new OSD. Consequently, it changes object placement, because it changes an input for the calculations. Thus rebalancing is done (unless a flag was enabled to not rebalance).

An erasure coded pool stores each object as `K+M` chunks. It is divided into `K` data chunks and `M` coding chunks. The pool is configured to have a size of `K+M` so that each chunk is stored in an OSD in the acting set. The rank of the chunk is stored as an attribute of the object.

For instance an erasure coded pool can be created to use five OSDs (`K+M = 5`) and sustain the loss of two of them (`M = 2`). Data may be unavailable until (`K+1`) shards are restored.

The default erasure code profile (which is created when the Ceph cluster is initialized) will split the data into 2 equal-sized chunks, and have 2 parity chunks of the same size. It will take as much space in the cluster as a 2-replica pool but can sustain the data loss of 2 chunks out of 4. It is described as a profile with k=2 and m=2, meaning the information is spread over four OSD (k+m == 4) and two of them can be lost.

## Planning a cluster

Make sure you wrap your head around the RAM and CPU to OSD ratios. Generally, more RAM is better. Monitor / Manager nodes for a modest cluster might do fine with 64GB; for a larger cluster with hundreds of OSDs 128GB is advised. There is an `osd_memory_target` setting for BlueStore OSDs that defaults to 4GB. Factor in a prudent margin for the operating system and administrative tasks (like monitoring and metrics) as well as increased consumption during recovery: provisioning ~8GB per BlueStore OSD is thus advised.

Do not deploy Ceph in production with less than five nodes. You need to keep Ceph under 80% full. When one of the nodes goes offline (e.g. failure or reboot), you are now working with 66% of the space. Of the 66%, you need to stay under 80% of that which is about 53% of the three node total. It is very easy to creep up and over 50% when everything is normal. Then be in a difficult place when you lose a node.

Ceph can use different size disks, however the disks should be as uniform as possible between the nodes. Otherwise the smaller nodes will fill up faster and be unable to honor its CRUSH rules even if there is space left.
