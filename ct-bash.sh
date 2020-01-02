#!/bin/bash
set -x
sudo chmod 777 /dev/ttyACM*
sudo setenforce Permissive
exec podman run \
    --rm \
    -it \
    --device=/dev/ttyACM0 \
    --device=/dev/ttyACM1 \
    --userns=keep-id \
    -v $(pwd):/wd:z \
    --workdir=/wd \
    zephyr-ct \
        /bin/bash "$@"
