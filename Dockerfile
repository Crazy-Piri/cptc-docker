# To create the image:
#   $ docker build -t cptc -f Dockerfile .
# To run the container:
#   $ docker run -v ${PWD}:/src/ -it cptc <command>

FROM ubuntu:latest

LABEL Version="0.2" \
    Date="2021-Jul-15" \
    Docker_Version="21.07.15 (2)" \
    Maintainer="RedBug/Crazy Piri (@crazypiri)" \
    Description="A basic Docker container to compile and use sdcc from GIT"

ENV SDCC_PATH="/tmp/sdcc" \
    SDCC_HOME="/tmp/sdcc"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y g++ libfreeimage-dev cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev clang git ca-certificates wget make patch gcc bzip2 unzip g++ texinfo bison flex libboost-dev libsdl1.2-dev pkgconf libfreetype6-dev libncurses-dev cmake vim zip php php-mbstring php-gd bsdmainutils \
    libc6-amd64-cross libstdc++6-amd64-cross php-yaml \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/x86_64-linux-gnu/lib /lib64

COPY tools /tmp/tools

RUN wget -O /tmp/sdcc.tar.bz2 "https://downloads.sourceforge.net/project/sdcc/sdcc/4.0.0/sdcc-src-4.0.0.tar.bz2" \
    && cd /tmp \
    && rm -rf ${SDCC_PATH} \
    && tar xvjf sdcc.tar.bz2 \
    && mv sdcc-4.0.0 sdcc \
    && cd ${SDCC_PATH} \
    && ./configure \
    --disable-avr-port \                                               
    --disable-xa-port \                                                
    --disable-mcs51-port \                                             
    --disable-z180-port \                                              
    --disable-r2k-port \                                               
    --disable-r3ka-port \                                              
    --disable-gbz80-port \                                             
    --disable-ds390-port \                                             
    --disable-ds400-port \                                             
    --disable-pic14-port \                                             
    --disable-pic16-port \                                        
    --disable-hc08-port \                                         
    --disable-s08-port \                                          
    --disable-tlcs90-port \                      
    --disable-st7-port \                         
    --disable-stm8-port \                        
    --disable-ucsim \
    && make \
    && make install \
    && rm -rf /tmp/sdcc /tmp/sdcc.tar.bz2

RUN cd /tmp/tools/idsk \
    && cmake CMakeLists.txt \
    && make \
    && mv iDSK /usr/local/bin/ \
    && rm -rf /tmp/tools/idsk

RUN cd /tmp/tools/hex2bin \
    && make \
    && mv hex2bin /usr/local/bin/ \
    && rm -rf /tmp/tools/hex2bin

RUN cd /tmp/tools/tzx2wav \
    && make \
    && mv tzx2wav /usr/local/bin/ \
    && rm -rf /tmp/tools/tzx2wav

RUN cd /tmp/tools/nocart/src \
    && make

RUN mkdir /tmp/martine\
    && cd /tmp/martine\
    && wget https://github.com/jeromelesaux/martine/releases/download/v0.26/martine-0.26.0-linux.zip\
    && unzip martine-0.26.0-linux.zip\
    && mv martine /usr/local/bin \
    && rm -rf /tmp/martine

RUN cd /tmp \
    && git clone https://github.com/Crazy-Piri/Img2CPC.git \
    && cd Img2CPC/ \
    && mkdir obj \
    && make -f Makefile.others \
    && cp bin/img2cpc /usr/local/bin/ \
    && rm -rf /tmp/Img2CPC

# RUN cd /tmp\
# 	&& mkdir skia\
# 	&& cd skia\
# 	&& wget https://github.com/aseprite/skia/releases/download/m81-b607b32047/Skia-Linux-Release-x64.zip\
# 	&& unzip Skia-Linux-Release-x64.zip\
# 	&& cd /tmp\
# 	&& git clone --recursive https://github.com/aseprite/aseprite.git\
# 	&& cd aseprite\
# 	&& mkdir build\
# 	&& cd build\
# 	&& cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DLAF_BACKEND=skia -DSKIA_DIR=/tmp/skia -DSKIA_LIBRARY_DIR=/tmp/skia/out/Release-x64 -DSKIA_LIBRARY=/tmp/skia/out/Release-x64/libskia.a -G Ninja ..\
# 	&& ninja aseprite\
# 	&& ln -s /tmp/aseprite/build/bin/aseprite /usr/local/bin

RUN cd /tmp \
    && git clone https://github.com/emmanuel-marty/lzsa.git \
    && cd lzsa/ \
    && make \
    && cp lzsa /usr/local/bin/ \
    && rm -rf /tmp/lzsa

RUN cd /tmp \
    && git clone https://github.com/EdouardBERGE/rasm.git \
    && cd rasm/ \
    && make \
    && cp rasm.exe /usr/local/bin/rasm \
    && rm -rf /tmp/rasm

RUN apt-get remove -y g++ cmake ninja-build libx11-dev libxcursor-dev libxi-dev libgl1-mesa-dev libfontconfig1-dev clang \
    && apt-get autoremove -y

ENV LD_LIBRARY_PATH="/usr/x86_64-linux-gnu/lib"

WORKDIR /src/
