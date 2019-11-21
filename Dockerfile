# Ubuntu 18.04 (Bionic)
FROM ubuntu:bionic-20191029

ARG DEBIAN_FRONTEND=noninteractive
RUN apt -y update
RUN apt -y install python2.7

# 1. Select and Update OS
# Zephyr development depends on an up-to-date host system and common build
# system tools. First, make sure your development system OS is updated:
RUN apt -y upgrade

# 2. Install dependencies
# Next, use a package manager to install required support tools. Python 3 and
# its package manager, pip, are used extensively by Zephyr for installing and
# running scripts used to compile, build, and run Zephyr applications.
# We’ll also install Zephyr’s multi-purpose west tool.
# 2.1
RUN apt -y install --no-install-recommends git cmake ninja-build gperf \
  ccache dfu-util device-tree-compiler wget \
  python3-pip python3-setuptools python3-tk python3-wheel xz-utils file \
  make gcc gcc-multilib
# 2.2.a
RUN apt -y install gnupg
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -
# 2.2.b
RUN apt -y install software-properties-common
RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
# 2.2.c
RUN apt -y update && apt -y install cmake && cmake --version
# 2.3
RUN pip3 install west

# 3. Get the source code
# Zephyr’s multi-purpose west tool simplifies getting the Zephyr project git
# repositories and external modules used by Zephyr. Clone all of Zephyr’s git
# repositories in a new zephyrproject directory using west:
WORKDIR /root
RUN west init zephyrproject
RUN cd zephyrproject && west update

# 4. Install needed Python packages
# The Zephyr source folders we downloaded contain a requirements.txt file that
# we’ll use to install additional Python tools used by the Zephyr project:
RUN pip3 install -r /root/zephyrproject/zephyr/scripts/requirements.txt

# 5. Install Software Development Toolchain
# A toolchain includes necessary tools used to build Zephyr applications
# including: compiler, assembler, linker, and their dependencies.
# Zephyr’s Software Development Kit (SDK) contains necessary Linux development
# tools to build Zephyr on all supported architectures. Additionally, it
# includes host tools such as custom QEMU binaries and a host compiler
RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.3/zephyr-sdk-0.10.3-setup.run && \
    chmod +x zephyr-sdk-0.10.3-setup.run && \
    ./zephyr-sdk-0.10.3-setup.run -- -d /root/zephyr-sdk-0.10.3 && \
    rm -rf zephyr-sdk-0.10.3-setup.run
ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/root/zephyr-sdk-0.10.3
# The SDK contains a udev rules file that provides information needed to
# identify boards and grant hardware access permission to flash tools. Install
# these udev rules with these commands:
RUN apt -y install udev
RUN cp /root/zephyr-sdk-0.10.3/sysroots/x86_64-pokysdk-linux/usr/share/openocd/contrib/60-openocd.rules \
        /etc/udev/rules.d
#udevadm control --reload

# 6. Build the Blinky Application
# The sample Blinky Application blinks an LED on the target board. By building
# and running it, we can verify that the environment and tools are properly set
# up for Zephyr development.
# This west command uses the -p auto parameter to automatically clean out any
# byproducts from a previous build if needed, useful if you try building
# another sample.
RUN bash -c "cd zephyrproject/zephyr && \
    source zephyr-env.sh && \
    west build -p auto -b nrf52840_papyr samples/basic/blinky"

WORKDIR zephyrproject/zephyr

RUN apt -y install libpython2.7
# Run with --privileged
# Then run "west flash" to flash
