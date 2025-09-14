---
title: "GMKtec NucBox K10"
---

!!! info
    [GMKtec NucBox K10](https://www.gmktec.com/products/gmktec-k10-intel-13th-core-i9-13900hk-mini-pc)

## Benchmarks against DL 380 G9

Green:

- Processor: Intel Core i9-13900HK @ 5.20GHz (14 Cores / 20 Threads)
- Motherboard: GMKtec (NucBox K10 0.12 BIOS)
- Chipset: Intel Alder Lake PCH
- Memory: 2 x 32 GB DDR5-5200MT/s
- Disk: 1000GB CT1000E100SSD8
- Graphics: Intel Raptor Lake-P [Iris Xe] (1500MHz)
- Audio: Conexant SN6140
- Network: Realtek RTL8125 2.5GbE + Intel Raptor Lake PCH CNVi WiFi
- OS: Rocky Linux 10.0
- Kernel: 6.12.0-55.22.1.el10_0.x86_64 (x86_64)
- Compiler: GCC 14.2.1 20250110
- File-System: xfs
- Physical dimensions: 9.8 x 10.3 x 4.2 cm
- Weight: 2.2kg
- Power draw (idle): 18W
- Power draw (max): 120W


Sol:

- Processor: 2 x Intel Xeon E5-2637 v3 @ 3.70GHz (8 Cores / 16 Threads)
- Motherboard: HP ProLiant DL380 Gen9 (P89 BIOS)
- Chipset: Intel Xeon E7 v3/Xeon
- Memory: 16 x 16 GB DDR4-2133MT/s 752369-081
- Disk: 2400GB LOGICAL VOLUME (8x600GB 10K SAS RAID10 Storage Controller HP Smart Array P440ar)
- Graphics: Matrox MGA G200EH
- Network: 4 x Broadcom NetXtreme BCM5719 PCIe
- OS: Debian 12
- Kernel: 6.8.12-9-pve (x86_64)
- Compiler: GCC 12.2.0
- File-System: ext4
- Physical dimensions: 8.73 x 44.55 x 67.94 cm
- Weight: 23.6 kg
- Power draw (idle): 112W
- Power draw (max): 500W

### CPU Benchmarks

Sol has: 2 x Intel Xeon E5-2637 v3 @ 3.70GHz (8 Cores / 16 Threads)

Green has: Intel Core i9-13900HK @ 5.20GHz (14 Cores / 20 Threads)

Results on openbenchmarking.org:

- [https://openbenchmarking.org/result/2509137-NE-SOLCPU35817](https://openbenchmarking.org/result/2509137-NE-SOLCPU35817)
- [https://openbenchmarking.org/result/2509117-NE-GREENCPU761](https://openbenchmarking.org/result/2509137-NE-SOLCPU35817)

| Test | Green | Sol | Difference |
|------|-----------|---------|------------|
| **x265 4K** | 5.91 fps | 5.55 fps | ~1.1x faster |
| **x265 1080p** | 20.98 fps | 15.57 fps | ~1.3x faster |
| **7-Zip Compression** | 90,807 MIPS | 48,654 MIPS | ~1.9x faster |
| **7-Zip Decompression** | 57,362 MIPS | 42,452 MIPS | ~1.4x faster |
| **Kernel Compile time** | 122.9 s | 227.1 s | ~1.8x faster |
| **OpenSSL SHA256** | 12.9 GB/s | 2.3 GB/s | ~5.6x faster |
| **OpenSSL SHA512** | 4.33 GB/s | 2.43 GB/s | ~1.8x faster |
| **RSA4096 Sign** | 2095 ops/s | 1299 ops/s | ~1.6x faster |
| **RSA4096 Verify** | 132,978 ops/s | 87,888 ops/s | ~1.5x faster |
| **AES-128-GCM** | 65.8 GB/s | 28.4 GB/s | ~2.3x faster |
| **AES-256-GCM** | 57.3 GB/s | 21.9 GB/s | ~2.6x faster |
| **ChaCha20** | 26.4 GB/s | 27.0 GB/s | ~1.0x (equal) |
| **ChaCha20-Poly1305** | 14.9 GB/s | 16.9 GB/s | ~0.1x slower (Xeon wins!) |
| **Redis GET (50 conn)** | 4.33M req/s | 2.15M req/s | ~2.0x more |
| **Redis GET (500 conn)** | 2.66M req/s | 1.96M req/s | ~1.4x more |
| **Redis GET (1000 conn)** | 2.32M req/s | 2.18M req/s | ~1.1x more |
| **Redis SET (50 conn)** | 2.79M req/s | 1.69M req/s | ~1.6x more |
| **Redis SET (500 conn)** | 2.24M req/s | 1.66M req/s | ~1.3x more |
| **Redis SET (1000 conn)** | 2.31M req/s | 1.69M req/s | ~1.4x more |
| **Redis LPOP (50 conn)** | 4.43M req/s | 2.42M req/s | ~1.8x more |
| **Redis LPOP (500 conn)** | 3.14M req/s | 2.46M req/s | ~1.3x more |
| **Redis LPOP (1000 conn)** | 2.72M req/s | 1.55M req/s | ~1.8x more |
| **Redis LPUSH (50 conn)** | 2.75M req/s | 1.12M req/s | ~2.5x more |
| **Redis LPUSH (500 conn)** | 1.79M req/s | 1.54M req/s | ~1.2x more |
| **Redis LPUSH (1000 conn)** | 1.79M req/s | 1.49M req/s | ~1.2x more |
| **Redis SADD (50 conn)** | 3.07M req/s | 1.93M req/s | ~1.6x more |
| **Redis SADD (500 conn)** | 2.57M req/s | 1.85M req/s | ~1.4x more |
| **Redis SADD (1000 conn)** | 2.48M req/s | 1.97M req/s | ~1.3x more |
| **MariaDB (1 client)** | 2685 QPS | 207 QPS | ~13.0x more |
| **MariaDB (32 clients)** | 2055 QPS | 103 QPS | ~20.0x more |
| **MariaDB (64 clients)** | 1621 QPS | 76 QPS | ~21.0x more |
| **MariaDB (128 clients)** | 820 QPS | 44 QPS | ~18.6x more |
| **MariaDB (256 clients)** | 397 QPS | 7 QPS | ~57x more |
| **MariaDB (512 clients)** | 184 QPS | 3 QPS | ~61x more |
| **MariaDB (1024-8192 clients)** | ~84-83 QPS | ~3 QPS | ~28x more |

#### CPU Benchmarks with only P-cores

Since i9-13900HK features [two kinds of cores](https://lwn.net/Articles/909611/), performance aka P-cores and efficiency aka E-cores (also known as Atom cores), it provided an interesting opportunity to test performance with E-cores off.

Check for E-cores: `cat /sys/devices/cpu_atom/cpus`

Run task on specific cores (0-11 are P-cores in this case): `taskset -c 0-11 <COMMAND>`

Results on openbenchmarking.org: [https://openbenchmarking.org/result/2509142-NE-CPUGREENN25](https://openbenchmarking.org/result/2509142-NE-CPUGREENN25)

| Test                          | All cores   | Only P-cores | Difference    |
| ----------------------------- | ----------- | ------------ | --------------|
| **x265 4K**                   | 5.91 fps    | 4.24 fps     | ~1.39x faster |
| **x265 1080p**                | 20.98 fps   | 17.51 fps    | ~1.20x faster |
| **7-Zip Compression**         | 90,807 MIPS | 64,768 MIPS  | ~1.40x faster |
| **7-Zip Decompression**       | 57,362 MIPS | 37,612 MIPS  | ~1.53x faster |
| **Linux Kernel Compile**      | 122.90 s    | 178.45 s     | ~1.45x faster |
| **OpenSSL SHA256**            | 12.90 GB/s  | 7.45 GB/s    | ~1.73x faster |
| **OpenSSL SHA512**            | 4.33 GB/s   | 2.66 GB/s    | ~1.63x faster |
| **OpenSSL RSA4096 Sign**      | 2,095 /s    | 1,625 /s     | ~1.29x faster |
| **OpenSSL RSA4096 Verify**    | 132,978 /s  | 104,828 /s   | ~1.27x faster |
| **OpenSSL ChaCha20**          | 26.41 GB/s  | 18.92 GB/s   | ~1.40x faster |
| **OpenSSL AES-128-GCM**       | 65.83 GB/s  | 38.84 GB/s   | ~1.70x faster |
| **OpenSSL AES-256-GCM**       | 57.26 GB/s  | 33.47 GB/s   | ~1.71x faster |
| **OpenSSL ChaCha20-Poly1305** | 14.91 GB/s  | 11.60 GB/s   | ~1.28x faster |
| **Redis GET (50 conns)**      | 4,334,402   | 1,038,531    | ~4.17x faster |
| **Redis SET (50 conns)**      | 2,789,408   | 1,037,535    | ~2.69x faster |
| **Redis GET (500 conns)**     | 2,664,632   | 1,756,982    | ~1.52x faster |
| **Redis LPOP (50 conns)**     | 4,426,627   | 796,807      | ~5.55x faster |
| **Redis SET (500 conns)**     | 2,238,991   | 1,425,186    | ~1.57x faster |
| **Redis LPOP (1000 conns)**   | 2,720,310   | 1,467,308    | ~1.85x faster |
| **Redis LPUSH (50 conns)**    | 2,748,150   | 688,325      | ~3.99x faster |
| **Redis SADD (500 conns)**    | 2,567,202   | 1,891,882    | ~1.36x faster |

Multi-threaded tasks benefit significantly from E-cores. Decompression sees a bigger relative improvement, likely due to better multi-thread scaling. Full core usage speeds up compilation by about a third. 

Single-threaded or lightly threaded tasks benefit less but still gain some improvement when E-cores assist background threads.

Redis throughput improves dramatically with E-cores enabled, especially at lower concurrency where single-thread performance matters less, and total parallelism dominates.

For mixed workloads (databases, Redis, compression, video encoding), enabling all cores is needed for maximum performance. Disabling E-cores mainly limits total throughput for parallel tasks.

#### CPU Benchmarks with only one CPU on dual socket

Since Sol has two CPU sockets and dual CPUs, it was interesting to run benchmarks only on one of them to see a difference in terms of more equal comparison in terms of core/thread counts between the systems and, perhaps, to see how much [NUMA](https://www.kernel.org/doc/html/v6.13-rc5/mm/numa.html) [affects](https://frankdenneman.nl/category/numa/) the results.

Run task only on first CPU: `numactl --cpubind=0 --membind=0 <COMMAND>`

Results on openbenchmarking.org:

| Test                          | Both CPUs   | Only first CPU | Difference    |
| ----------------------------- | ----------- | -------------- | --------------|


#### CPU Bench Summary

| Test | Winner | Difference |
|----------|--------|------------|
| **Video Encoding (x265)** | Green | ~1.1-1.3x faster |
| **Compression (7-Zip)** | Green | ~1.4-1.9x faster | 
| **Kernel Compilation** | Green | ~1.8x faster | 
| **Cryptography (SHA, RSA, AES)** | Green | ~1.5-5.6x faster |
| **Cryptography (ChaCha20/Poly1305)** | sol | ~1.1x faster |
| **Redis (in-memory DB)** | Green | ~1.2-2.5x more req/s |
| **MariaDB (SQL DB)** | Green | ~13-61x more QPS |

Green has way better IPC with modern architecture, and in some cases can beat parallel loads (7-Zip compression) even if Sol has more threads.

Cryptography improvements likely due to AVX2/AVX512 and AES-NI optimizations on Alder Lake vs Haswell-era Xeons. Surprisingly ChaCha20 performance is equal or even slightly better on Sol, indicating that Green's crypto accelerators favor AES but not ChaCha20. Also RSA4096 and other public-key operations scale less dramatically (~1.5-1.6x), reflecting their compute-bound nature with less dependency on memory bandwidth. ChaCha20 being faster on older Xeon is a rare scenario where lack of AES acceleration helps.

Green consistently outperforms Sol on Redis benchmarks. However at higher concurrent connections, performance delta shrinks slightly, indicating that memory and I/O subsystem become the bottleneck at scale.

MariaDB results in a massive difference in performance not just due to CPU but also NVMe vs RAID SAS latency. CPU cannot shine fully if disk latency dominates.

### Disk Benchmarks

Sol has: 2400GB LOGICAL VOLUME (8x600GB 10K SAS RAID10 Storage Controller HP Smart Array P440ar) on ext4

Green has: NVMe 1000GB CT1000E100SSD8 on xfs

Results on openbenchmarking.org:

- [https://openbenchmarking.org/result/2509115-NE-DISKGREEN01](https://openbenchmarking.org/result/2509115-NE-DISKGREEN01)
- [https://openbenchmarking.org/result/2509145-NE-DISKSOL7014](https://openbenchmarking.org/result/2509145-NE-DISKSOL7014)

| Test | Green | Sol | Difference |
|------|------------|----------|------------|
| SQLite 1 thread |  9.747 s | 231.45 s | ~24x faster |
| SQLite 2 threads | 19.32 s | 416.77 s | ~22x faster |
| SQLite 4 threads | 18.64 s | 556.95 s | ~30x faster |
| SQLite 8 threads | 32.27 s | 719.51 s | ~22x faster |
| SQLite 16 threads | 48.89 s | 948.19 s | ~19x faster |
| FIO Random Write 2MB MB/s | 1.187 GB/s | 0.477 GB/s | ~2.5x faster |
| FIO Random Write 4KB MB/s | 1.176 GB/s | 0.489 GB/s | ~2.4x faster |
| FIO Sequential Read 2MB MB/s | 1.955 GB/s | 0.884 GB/s | ~2.2x faster |
| FIO Sequential Read 4KB MB/s | 1.942 GB/s | 0.870 GB/s | ~2.2x faster |
| FIO Sequential Write 2MB MB/s | 1.523 GB/s | 0.737 GB/s | ~2.1x faster |
| FIO Sequential Write 4KB MB/s | 1.501 GB/s | 0.761 GB/s | ~2x faster |
| FS-Mark 1000 Files | 829.7 files/s | 43.7 files/s | ~19x faster |
| FS-Mark 4000 Files, 32 Dirs | 805.8 files/s | 44.8 files/s | ~18x faster |
| Dbench 1 client | 398.87 MB/s | 24.40 MB/s | ~16x faster |
| Dbench 12 clients | 2047.02 MB/s | 127.63 MB/s | ~16x faster |
| IOR 2MB / MB/s | 2608.21 | 199.94 | ~13x faster |
| IOR 4MB / MB/s | 2897.53 | 236.61 | ~12x faster |
| IOR 8MB / MB/s | 3085.04 | 308.99 | ~10x faster |
| IOR 16MB / MB/s | 3168.04 | 346.90 | ~9x faster |
| IOR 32MB / MB/s | 2879.00 | 407.15 | ~7x faster |
| IOR 64MB / MB/s | 2875.59 | 465.83 | ~6x faster |
| IOR 256MB / MB/s | 3049.90 | 459.17 | ~6.6x faster |
| IOR 512MB / MB/s | 2986.88 | 409.78 | ~7.3x faster |
| IOR 1024MB / MB/s | 3391.72 | 382.75 | ~8.9x faster |

#### Disk Benchmark Summary

| Test | Winner | Difference |
|------|--------|------------|
| SQLite (1-16 threads) | Green |  ~19-30x faster |
| FIO Random Write 2MB / 4KB | Green | ~2-2.5x faster |
| FIO Sequential Read 2MB / 4KB | Green | ~2.2x faster |
| FIO Sequential Write 2MB / 4KB | Green | ~2x faster |
| FS-Mark small files | Green | ~18-19x faster |
| Dbench (1/12 clients) | Green | ~16x faster |
| IOR small blocks (2-8MB) | Green | ~10-13x faster |
| IOR medium blocks (16-64MB) | Green | ~6-9x faster |
| IOR large blocks (256-1024MB) | Green | ~6-9x faster |

SMP performance due to DDR5's higher frequency and wider bus per channel.

STREAM benchmarks favor Sol which is likely due to Sol's 4-channel DDR4 memory configuration (16 DIMMs across 2 CPUs), providing higher aggregate bandwidth despite slower individual DIMMs. STREAM favoring Sol shows multi-channel DDR4 can beat DDR5 for large sequential streams, but only for continuous bulk operations.

Green shows enormous advantage in cache writes, reflecting modern CPU caches with higher associativity and faster L2/L3.

Green's memcpy/memset performance shows low-latency benefits for small-block memory operations.

Threaded memory operations show Green's superior per-thread latency and IPC, particularly in multi-threaded small-memory scenarios.

Green benefits from modern DDR5 and low-latency caches for small-block memory and per-thread operations, whereas Sol's memory excels in sustained high-bandwidth workloads due to many-channel DDR4 configuration.

### RAM Benchmarks

Sol has: 16 x 16 GB DDR4-2133MT/s 752369-081

Green has: 2 x 32 GB DDR5-5200MT/s

Results on openbenchmarking.org:

- https://openbenchmarking.org/result/2509141-NE-RAMSOL48015
- https://openbenchmarking.org/result/2509145-NE-RAMGREEN277

| Test                                  | Green          | Sol            | Difference    |
| ------------------------------------- | -------------- | -------------- | ------------- |
| RAMspeed SMP Add (Integer)            | 49170.75 MB/s  | 25245.05 MB/s  | ~1.9x faster |
| RAMspeed SMP Copy (Integer)           | 46294.82 MB/s  | 24593.03 MB/s  | ~1.9x faster |
| RAMspeed SMP Scale (Integer)          | 44536.78 MB/s  | 22317.15 MB/s  | ~2x faster   |
| RAMspeed SMP Triad (Integer)          | 47968.84 MB/s  | 24709.48 MB/s  | ~1.9x faster |
| RAMspeed SMP Average (Integer)        | 44173.83 MB/s  | 24336.00 MB/s  | ~1.8x faster |
| RAMspeed SMP Add (Floating Point)     | 45365.78 MB/s  | 26331.63 MB/s  | ~1.7x faster |
| RAMspeed SMP Copy (Floating Point)    | 43004.43 MB/s  | 25118.17 MB/s  | ~1.7x faster |
| RAMspeed SMP Scale (Floating Point)   | 42716.91 MB/s  | 22584.29 MB/s  | ~1.9x faster |
| RAMspeed SMP Triad (Floating Point)   | 44670.74 MB/s  | 26515.81 MB/s  | ~1.7x faster |
| RAMspeed SMP Average (Floating Point) | 43906.89 MB/s  | 25257.18 MB/s  | ~1.7x faster |
| Stream Copy                           | 64740.8 MB/s   | 85814.2 MB/s   | ~1.3x slower |
| Stream Scale                          | 54172.5 MB/s   | 65886.2 MB/s   | ~1.2x slower |
| Stream Triad                          | 56556.2 MB/s   | 71293.8 MB/s   | ~1.3x slower |
| Stream Add                            | 56446.8 MB/s   | 71080.0 MB/s   | ~1.3x slower |
| Tinymembench Memcpy                   | 28540.4 MB/s   | 9522.9 MB/s    | ~3x faster   |
| Tinymembench Memset                   | 56744.2 MB/s   | 5950.6 MB/s    | ~9.5x faster |
| MBW Memory Copy                       | 26202.42 MiB/s | 11409.51 MiB/s | ~2.3x faster |
| MBW Memory Copy Fixed Block           | 14090.10 MiB/s | 4169.46 MiB/s  | ~3.4x faster |
| t-test1 Threads 1                     | 18.05 s        | 32.38 s        | ~1.8x faster |
| t-test1 Threads 2                     | 5.814 s        | 16.51 s        | ~2.8x faster |
| CacheBench Read Cache                 | 20550.62 MB/s  | 9333.97 MB/s   | ~2.2x faster |
| CacheBench Write Cache                | 268593.70 MB/s | 41921.13 MB/s  | ~6.4x faster |

#### RAM Benchmark Summary

| Test                          | Winner | Difference        |
| ----------------------------- | ------ | ----------------- |
| RAMspeed SMP (Integer)        | Green  | ~1.8-2x faster   |
| RAMspeed SMP (Floating Point) | Green  | ~1.7x faster     | 
| Stream                        | Sol    | ~1.2-1.3x faster |
| Tinymembench Memcpy           | Green  | ~3x faster       |
| Tinymembench Memset           | Green  | ~9.5x faster     |
| MBW Memory Copy               | Green  | ~2.3x faster     |
| MBW Memory Copy Fixed Block   | Green  | ~3.4x faster     |
| t-test1 Threads 1             | Green  | ~1.8x faster     |
| t-test1 Threads 2             | Green  | ~2.8x faster     |
| CacheBench Read Cache         | Green  | ~2.2x faster     |
| CacheBench Write Cache        | Green  | ~6.4x faster     |

SQLite single-threaded performance shows 24x advantage for Green; even with multiple threads, Green dominates. NVMe latency vs SAS explains this.

FIO sequential/random throughput is 2-2.5x higher on Green. NVMe scales better due to deep queue depth and modern controller efficiency.

IOR shows Green achieving 6-13x higher MB/s, with the delta shrinking for very large I/O blocks (32-1024MB). This suggests that RAID10 overhead in Sol becomes less significant for very large sequential transfers, but NVMe still dominates.

FS-Mark and Dbench show Green is ~16-19x faster. This is the combined effect of NVMe low latency, XFS efficiency, and fewer mechanical seek delays than 10K SAS disks.

NVMe SSDs provide massive latency and throughput advantages for small and large workloads alike. RAID10 SAS arrays are good for sustained large-block transfers, but fall behind in low-latency, metadata-heavy scenarios.

### Overall notes

Green's smaller core count is offset by high IPC, modern caches, and DDR5 bandwidth. Many benchmarks (MariaDB, Redis, crypto) show that per-core performance is more important than total threads, especially for latency-sensitive workloads.

MariaDB and SQLite show extreme differences, not just due to CPU but also NVMe vs RAID SAS latency.

High-speed RAM benefits NVMe latency hiding. Small-block I/O (SQLite, Dbench) benefits from Green's faster memory and cache hierarchy. Sol's large-channel memory helps for sustained sequential FIO reads, but cannot compensate for mechanical seek times in small-block workloads.

Enterprise Xeons still shine in extreme multi-threaded sequential memory or I/O scenarios, but their architecture is tuned for consistency and parallel throughput, not latency-sensitive operations.
