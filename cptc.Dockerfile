# To create the image:
#   $ docker build -t z88dk -f z88dk.Dockerfile .
# To run the container:
#   $ docker run -v ${PWD}:/src/ -it z88dk <command>

FROM ubuntu:latest

LABEL Version="0.1" \
      Date="2020-Jun-08" \
      Docker_Version="20.06.08 (1)" \
      Maintainer="RedBug/Crazy Piri (@crazypiri)" \
      Description="A basic Docker container to compile and use sdcc from GIT"

ENV Z88DK_PATH="/opt/z88dk" \
    SDCC_PATH="/tmp/sdcc" \
    SDCC_HOME="/tmp/sdcc"

RUN apt-get update

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y tzdata \
    && ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    && apt-get install -y git ca-certificates wget make patch gcc bzip2 unzip g++ texinfo bison flex libboost-dev libsdl1.2-dev pkgconf libfreetype6-dev libncurses-dev cmake vim zip php php-mbstring bsdmainutils

# Add, edit or uncomment the following lines to customize the z88dk compilation
# COPY clib_const.m4 ${Z88DK_PATH}/libsrc/_DEVELOPMENT/target/
# COPY config_sp1.m4 ${Z88DK_PATH}/libsrc/_DEVELOPMENT/target/zx/config/

# RUN wget -O /tmp/sdcc.tar.bz2 "https://downloads.sourceforge.net/project/sdcc/sdcc/3.9.0/sdcc-src-3.9.0.tar.bz2" \

COPY tools /tmp/tools

#    && ./configure  --prefix="/tmp/sdcc"\

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
    && make install

RUN cd /tmp/tools/idsk \
    && cmake CMakeLists.txt \
    && make \
    && mv iDSK /usr/local/bin/

RUN cd /tmp/tools/hex2bin \
    && make \
    && mv hex2bin /usr/local/bin/

RUN cd /tmp/tools/nocart/src \
    && make

RUN apt-get -y install libfreeimage-dev \
    && cd /tmp \
    && git clone https://github.com/Crazy-Piri/Img2CPC.git \
    && cd Img2CPC/ \
    && mkdir obj \
    && make -f Makefile.others \
    && cp bin/img2cpc /usr/local/bin/

ENV PATH="${Z88DK_PATH}/bin:${PATH}" \
    ZCCCFG="${Z88DK_PATH}/lib/config/"

WORKDIR /src/
