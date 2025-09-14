---
title: "Benchmarking and Performance Testing"
---

!!! info
    [Kubernetes Docs](https://kubernetes.io/docs/home/) |
    [Cloud Native Landscape](https://landscape.cncf.io/) |
    [Kubernetes Secrets threat model](https://www.macchaffee.com/blog/2022/k8s-secrets/) |
    [Managing Kubernetes without losing your cool](https://marcusnoble.co.uk/2022-07-04-managing-kubernetes-without-losing-your-cool/)

### Full Suite Testing

[Phoronix Test Suite](https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/documentation/phoronix-test-suite.md)

1. Find [latest Phoronix release](https://github.com/phoronix-test-suite/phoronix-test-suite/releases/latest)
2. Get Phoronix: `wget https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/v10.8.4/phoronix-test-suite-10.8.4.tar.gz`
3. Unpack: `tar -xvzf phoronix-test-suite-10.8.4.tar.gz`
4. Change directory: `cd phoronix-test-suite/`
5. Install dependencies:
   - `dnf install php-cli php-xml php-json gd gd-devel`
   - `sudo apt-get install php-cli php-xml libgd-dev`
6. Browse suites at [openbenchmarking.org](https://openbenchmarking.org/suites)
7. And run them with `sh phoronix-test-suite <ARGS>`

Tests will be saved in `~/.phoronix-test-suite/test-results/*`. Run `sh phoronix-test-suite list-saved-results` to list results and then view specific result with `sh phoronix-test-suite show-result <RESULT NAME>`.

Selected tests:

- For CPU:

    ```bash
    sh phoronix-test-suite install compress-7zip mysqlslap openssl redis build-linux-kernel x265 dav1d

    sh phoronix-test-suite benchmark compress-7zip mysqlslap openssl redis build-linux-kernel x265 dav1d
    ```

- For memory:

    ```bash
    sh phoronix-test-suite benchmark memory
    ```

- For disk:

    ```bash
    sh phoronix-test-suite benchmark disk
    ```

### Disk performance testing with FIO

[Flexible I/O tester docs](https://fio.readthedocs.io/en/latest/fio_doc.html)
[fio output explained](https://tobert.github.io/post/2014-04-17-fio-output-explained.html)
[ArsTechnica fio recommended tests](https://arstechnica.com/gadgets/2020/02/how-fast-are-your-disks-find-out-the-open-source-way-with-fio/)

#### Single 4KiB random write process

This is a single process doing random 4K writes. This is where the pain really, really lives; it's basically the worst possible thing you can ask a disk to do. Where this happens most frequently in real life: copying home directories and dotfiles, manipulating email stuff, some database operations, source code trees.

```bash
fio --filename=sdX --name=random-write --ioengine=posixaio --rw=randwrite --bs=4k --size=4g --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1
```


#### 16 parallel 64KiB random write processes

This time, we're creating 16 separate 256MB files (still totaling 4GB, when all put together) and we're issuing 64KB blocksized random write operations. We're doing it with sixteen separate processes running in parallel, and we're queuing up to 16 simultaneous asynchronous ops before we pause and wait for the OS to start acknowledging their receipt. This is a pretty decent approximation of a significantly busy system. It's not doing any one particularly nasty thing—like running a database engine or copying tons of dotfiles from a user's home directory—but it is coping with a bunch of applications doing moderately demanding stuff all at once.

This is also a pretty good, slightly pessimistic approximation of a busy, multi-user system like a NAS, which needs to handle multiple 1MB operations simultaneously for different users. If several people or processes are trying to read or write big files (photos, movies, whatever) at once, the OS tries to feed them all data simultaneously. This pretty quickly devolves down to a pattern of multiple random small block access. So in addition to "busy desktop with lots of apps," think "busy fileserver with several people actively using it."

```bash
fio --filename=sdX --name=random-write --ioengine=posixaio --rw=randwrite --bs=64k --size=256m --numjobs=16 --iodepth=16 --runtime=60 --time_based --end_fsync=1
```

#### Single 1MiB random write process

This is pretty close to the best-case scenario for a real-world system doing real-world things. No, it's not quite as fast as a single, truly contiguous write... but the 1MiB blocksize is large enough that it's quite close. Besides, if literally any other disk activity is requested simultaneously with a contiguous write, the "contiguous" write devolves to this level of performance pretty much instantly, so this is a much more realistic test of the upper end of storage performance on a typical system.

You'll see some kooky fluctuations on SSDs when doing this test. This is largely due to the SSD's firmware having better luck or worse luck at any given time, when it's trying to queue operations so that it can write across all physical media stripes cleanly at once. Rust disks will tend to provide a much more consistent, though typically lower, throughput across the run.

You can also see SSD performance fall off a cliff here if you exhaust an onboard write cache—TLC and QLC drives tend to have small write cache areas made of much faster MLC or SLC media. Once those get exhausted, the disk has to drop to writing directly to the much slower TLC/QLC media where the data eventually lands. This is the major difference between, for example, Samsung EVO and Pro SSDs—the EVOs have slow TLC media with a fast MLC cache, where the Pros use the higher-performance, higher-longevity MLC media throughout the entire SSD.

```bash
fio --filename=sdX --name=random-write --ioengine=posixaio --rw=randwrite --bs=1m --size=16g --numjobs=1 --iodepth=1 --runtime=60 --time_based --end_fsync=1
```