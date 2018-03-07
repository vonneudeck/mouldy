FROM marcelstoer/nodemcu-build

ENV NODEMCU_VERSION 2.1.0-master_20170824

RUN apt-get -qy update && \
    apt-get -qy install python3-pip && \
    pip3 install esptool && \
    pip3 install nodemcu-uploader && \
    git init && \
    git remote add origin https://github.com/nodemcu/nodemcu-firmware.git && \
    git fetch --depth 1 origin $NODEMCU_VERSION && \
    git checkout FETCH_HEAD

COPY files/ .
RUN /opt/cmd.sh
