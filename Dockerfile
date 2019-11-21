FROM fedora:31
RUN dnf -y install python3 python3-pip git wget which xz bzip2

RUN python3 -m pip install west

RUN mkdir /zephyr
WORKDIR /zephyr
RUN west init project && \
    cd project && \
    west update

RUN python3 -m pip install -r project/zephyr/scripts/requirements.txt

RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.10.3/zephyr-sdk-0.10.3-setup.run && \
    chmod +x zephyr-sdk-0.10.3-setup.run && \
    ./zephyr-sdk-0.10.3-setup.run -- -d /opt/zephyr-sdk && \
    rm -rf zephyr-sdk-0.10.3-setup.run

RUN dnf -y install cmake dtc

ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk

RUN bash -c 'echo "cd /zephyr/project/zephyr; source zephyr-env.sh; cd /zephyr" > /zephyr/bashrc'
CMD ["bash", "--rcfile", "/zephyr/bashrc"]

RUN west init project2 && \
    cd project2 && \
    west update
RUN bash -c 'echo "cd /zephyr/project2/zephyr; source zephyr-env.sh; cd /zephyr" > /zephyr/bashrc'
