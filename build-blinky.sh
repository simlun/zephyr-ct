#!/usr/bin/env ./ct-bash.sh
if [ ! -e zproj ]; then
    west init zproj
    cd zproj
    west update
    cd ..
fi

cd zproj
cd zephyr
source zephyr-env.sh
west build -p auto -b nrf52840_papyr samples/basic/blinky
