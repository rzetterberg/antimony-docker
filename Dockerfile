FROM debian:jessie

# Install all library dependencies
RUN apt-get update --fix-missing && apt-get install -y \
    build-essential libpng-dev python3-dev libboost-all-dev libgl1-mesa-dev \
    lemon flex

# Setup the user that will be used when building the project.
RUN useradd -m -d /home/builder -s /bin/bash builder
RUN apt-get install -y sudo locales
RUN usermod -a -G sudo builder
RUN echo " builder      ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

# Setup right locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN mkdir /opt/builder && chown builder:builder /opt/builder
WORKDIR /opt/builder

RUN apt-get install git -y

# Install Qt 5.4 last so that everything else is cached
RUN echo "deb http://ftp.se.debian.org/debian/ stretch main" >> /etc/apt/sources.list.d/stretch.list
RUN apt-get update --fix-missing && apt-get -t stretch install qt5-default -y

USER builder

RUN git clone https://github.com/mkeeter/antimony && cd antimony && \
    git checkout tags/0.9.0c && mkdir build && cd build && \
    qmake ../sb.pro && make -j2

RUN mkdir antimony/build/app/share
WORKDIR /opt/builder/antimony/build/app/share
