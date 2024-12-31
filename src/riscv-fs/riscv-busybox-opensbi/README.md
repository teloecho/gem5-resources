---
title: RISC-V Full System in One Kernel Resource
tags:
    - fullsystem
    - bootloader
    - riscv
layout: default
permalink: resources/riscv-fs-busybox-opensbi
shortdoc: >
    Resources to build an OpenSBI bootloader with Linux image, initramfs and Busybox that works with gem5 full system simulations.
author: ["Jonathan Kretschmer"]
---

# RISC-V Linux Full System Bootloader, initramfs and Workload in One

This document provides instructions to create an
(OpenSBI)[https://github.com/riscv-software-src/opensbi] bootloader binary
with Linux kernel image payload containing an initramfs with
(Busybox)[https://www.busybox.net/] that works with gem5 full system simulations.

This guide is inspired by and partly copied from
(riscv-fs-nodisk)[https://github.com/gem5/gem5-resources/blob/stable/src/riscv-fs-alt/riscv-boot-exit-nodisk/README.md]
and (Linux on RISC-V using QEMU and BUSYBOX from scratch)[https://risc-v-machines.readthedocs.io/en/latest/linux/simple/].

For this guide we assume following directory structure. Gem5 source itself is
required either, but not listed here to avoid duplication.
```
riscv-all-in-one/
    ├── busybox/                # busybox source
    ├── cpio/                   # contains the .cpio file
    ├── initramfs/              # contains the structure of initramfs
    ├── linux/                  # linux source
    ├── opensbi/                # OpenSBI source, providing a RISC-V bootloader
    ├── riscv-gnu-toolchain/    # riscv tool chain for cross compilation
    └── README.md               # This README file
```

# Building the resource
## Step 1. Getting the `riscv-gnu-toolchain`

We'll use the precompiled toolchain for Debian 12 (Bookworm) System,
package `g++-12-riscv64-linux-gnu`, version `12.2.0-13cross1`.
Install it by running:

```sh
sudo apt install g++-12-riscv64-linux-gnu

# The shipped toolchain version might use weird `-12` suffixes. Setting custom
# toolchain suffixes in the makefiles is cumbersome, therefore link the tools
# to the regular prefix naming scheme.
# (Taken from [riscv-opensbi](src/riscv-fs/riscv-opensbi/build-env.dockerfile))
sudo su
ln -s /usr/bin/riscv64-linux-gnu-cpp-12 /usr/bin/riscv64-linux-gnu-cpp & \
ln -s /usr/bin/riscv64-linux-gnu-cpp-12 /usr/bin/riscv64-linux-gnu-cpp & \
ln -s /usr/bin/riscv64-linux-gnu-g++-12 /usr/bin/riscv64-linux-gnu-g++ & \
ln -s /usr/bin/riscv64-linux-gnu-gcc-12 /usr/bin/riscv64-linux-gnu-gcc & \
ln -s /usr/bin/riscv64-linux-gnu-gcc-ar-12 /usr/bin/riscv64-linux-gnu-gcc-ar & \
ln -s /usr/bin/riscv64-linux-gnu-gcc-nm-12 /usr/bin/riscv64-linux-gnu-gcc-nm & \
ln -s /usr/bin/riscv64-linux-gnu-gcc-ranlib-12 /usr/bin/riscv64-linux-gnu-gcc-ranlib & \
ln -s /usr/bin/riscv64-linux-gnu-gcov-12 /usr/bin/riscv64-linux-gnu-gcov & \
ln -s /usr/bin/riscv64-linux-gnu-gcov-dump-12 /usr/bin/riscv64-linux-gnu-gcov-dump & \
ln -s /usr/bin/riscv64-linux-gnu-gcov-tool-12 /usr/bin/riscv64-linux-gnu-gcov-tool & \
ln -s /usr/bin/riscv64-linux-gnu-lto-dump-12 /usr/bin/riscv64-linux-gnu-lto-dump
exit # the root mode
```

If you want to build the [GNU toolchain for RISC-V](https://github.com/riscv-collab/riscv-gnu-toolchain)
yourself, use the `--enable-multilib` flag on the `configure` step and `make` the
`linux` target.

## Step 2. Getting and Building `busybox`
More information about Busybox is [here](https://www.busybox.net/).
```sh
cd riscv-all-in-one/
git clone --branch 1_36_stable https://git.busybox.net/busybox.git

# alternatively downloading tar
wget https://git.busybox.net/busybox/snapshot/busybox-1_36_1.tar.bz2
tar xf busybox-1_36_1.tar.bz2
mv busybox-1_36_1 busybox

cd busybox
# create a default configuration
make CROSS_COMPILE=riscv64-linux-gnu- defconfig
make CROSS_COMPILE=riscv64-linux-gnu- menuconfig
# Configure static linking in order to simplify things.
# Settings --->
# Build Options --->
# Build static binary (no shared libs) ---> yes
make CROSS_COMPILE=riscv64-linux-gnu- all -j$(nproc)
make CROSS_COMPILE=riscv64-linux-gnu- install # optional
```
The files of interest are in `busybox/_install/bin`.

## Step 3. Compiling the Workload (e.g. gem5's m5)
Change to the directory with your clone of gem5 version `24.0.0.1`.
```sh
cd gem5/
cd util/m5
scons riscv.CROSS_COMPILE=riscv64-linux-gnu- build/riscv/out/m5
```
**Note**: the default cross-compiler is `riscv64-unknown-linux-gnu-`.

## Step 4. Determining the Structure of `initramfs`
Your Linux requires a *file system* in order to properly run. So we will
prepare the file structure and the `init` script.
```sh
cd riscv-all-in-one/
mkdir initramfs
cd initramfs
mkdir -p {bin,sbin,dev,etc,home,mnt,proc,sys,usr,tmp}
mkdir -p usr/{bin,sbin}
mkdir -p proc/sys/kernel
# Without following devices, we cannot see the output to `stdout` and `stderr`
fakeroot -- mknod -m 622 dev/console c 5 1
fakeroot -- mknod -m 622 dev/sda b 8 0
fakeroot -- mknod -m 622 dev/tty c 5 0
fakeroot -- mknod -m 622 dev/ttyprintk c 5 3
fakeroot -- mknod -m 622 dev/null c 1 3
```
**Note:** `mknod -m 622 /dev/tty c 5 0` means we're creating `/dev/tty` with
permission of `622`. `c` means a character device being created, `5` is the
major number, and `0` is the minor number. More information about the
major/minor numbering is available at
(https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/admin-guide/devices.txt).

Drop the `busybox` executable from the previous section into the filesystem:
```sh
cp ../busybox/busybox ./bin/
```
Drop the workload:
```sh
cp /path/to/your/gem5/util/m5/build/riscv/out/m5 ./sbin/m5 # replace m5 by the desired workload
```
After the kernel has started, we have to start Busybox and finalize the system
initialization. We will use a script called `init` that will do the hard work,
and finally starts the workload.
Create `initramfs/init` script with the following content,
```
#!/bin/busybox sh

# Make symlinks
/bin/busybox --install -s

# Mount system
mount -t devtmpfs  devtmpfs  /dev
mount -t proc      proc      /proc
mount -t sysfs     sysfs     /sys
mount -t tmpfs     tmpfs     /tmp

# Busybox TTY fix
setsid cttyhack sh

# https://git.busybox.net/busybox/tree/docs/mdev.txt?h=1_32_stable
echo /sbin/mdev > /proc/sys/kernel/hotplug
mdev -s

# enter a shell
#sh
# or execute the workload
/sbin/m5 exit # replace with desired workload
```
Add executable flag:
```sh
chmod +x init
```
At this stage, your initramfs should look like:
```sh
$ tree
.
├── bin
│   └── busybox
├── dev
│   ├── console
│   ├── null
│   ├── sda
│   ├── tty
│   └── ttyprintk
├── etc
├── home
├── init
├── mnt
├── proc
│   └── sys
│       └── kernel
├── sbin
│   └── m5
├── sys
├── tmp
└── usr
    ├── bin
    └── sbin

15 directories, 8 files
```
To create the cpio file from the `initramfs` folder,
```sh
mkdir riscv-all-in-one/cpio
cd riscv-all-in-one/initramfs
fakeroot -- find . -print0 | cpio --owner root:root --null -o --format=newc > ../cpio/initramfs.cpio
# alternatively with the tool available in the (previously build) linux kernel
#../linux/usr/gen_initramfs.sh -o ../cpio/initramfs.cpio ./
lsinitramfs ../cpio/initramfs.cpio # checking the file structure of the created cpio file
```

## Step 5. Compiling `Linux Kernel` with a customized `initramfs`
```sh
cd riscv-all-in-one/
git clone --depth 1 --branch v6.11 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git

# alternatively downloading tar
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.11.10.tar.xz
tar xf linux-6.11.10.tar.xz
mv linux-6.11.10 linux

cd linux
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- menuconfig
# Go to "General setup --->"
#   Check on "Initial RAM filesystem and RAM disk (initramfs/initrd) support"
#   Change "Initramfs source file(s)" to the absoblute path of riscv-all-in-one/cpio/initramfs.cpio
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- all -j$(nproc)
```
The file of interest is at `arch/riscv/boot/Image`.

## Step 6. Compiling `OpenSBI` with the Linux kernel as the payload
```sh
cd riscv-all-in-one/
git clone https://github.com/riscv-software-src/opensbi
cd opensbi
git switch --detach v1.4
make CROSS_COMPILE=riscv64-linux-gnu- PLATFORM=generic FW_PAYLOAD_PATH=../linux/arch/riscv/boot/Image -j$(nproc)
```
The desired bootloader file is at `build/platform/generic/firmware/fw_payload.elf`.

# Example

You can run the created bootloader with Linux and Busybox payload using the example riscv `fs_linux.py` config,
```sh
cd gem5
./build/RISCV/gem5.opt configs/example/riscv/fs_linux.py --kernel="../gem5-resources/src/riscv-fs/riscv-all-in-one/opensbi/build/platform/generic/firmware/fw_payload.elf"
```
You can check the console output with `telnet` or gem5's `m5term`,
```sh
telnet localhost <port>
# or
cd util/term
make
./m5term localhost <port>
```
